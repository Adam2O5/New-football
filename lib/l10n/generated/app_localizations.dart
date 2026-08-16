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

  /// No description provided for @mainMenu_exitGame.
  ///
  /// In pl, this message translates to:
  /// **'Opuść grę'**
  String get mainMenu_exitGame;

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

  /// No description provided for @loadGame_incompatibleOlder.
  ///
  /// In pl, this message translates to:
  /// **'Zapis pochodzi ze starszej wersji ({version}), wymagane jest {currentVersion}.'**
  String loadGame_incompatibleOlder(Object currentVersion, Object version);

  /// No description provided for @loadGame_incompatibleNewer.
  ///
  /// In pl, this message translates to:
  /// **'Zapis pochodzi z nowszej wersji ({version}), obsługiwana jest wersja {currentVersion}.'**
  String loadGame_incompatibleNewer(Object currentVersion, Object version);

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

  /// No description provided for @shell_tab_other.
  ///
  /// In pl, this message translates to:
  /// **'Inne'**
  String get shell_tab_other;

  /// No description provided for @shell_settingsTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Ustawienia'**
  String get shell_settingsTooltip;

  /// No description provided for @shell_saveTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz'**
  String get shell_saveTooltip;

  /// No description provided for @other_title.
  ///
  /// In pl, this message translates to:
  /// **'Inne'**
  String get other_title;

  /// No description provided for @other_workInProgress.
  ///
  /// In pl, this message translates to:
  /// **'W trakcie prac'**
  String get other_workInProgress;

  /// No description provided for @other_tradeHistory.
  ///
  /// In pl, this message translates to:
  /// **'Historia wymian'**
  String get other_tradeHistory;

  /// No description provided for @other_teamOverview.
  ///
  /// In pl, this message translates to:
  /// **'Przegląd drużyny'**
  String get other_teamOverview;

  /// No description provided for @other_finances.
  ///
  /// In pl, this message translates to:
  /// **'Finanse'**
  String get other_finances;

  /// No description provided for @teamOverview_title.
  ///
  /// In pl, this message translates to:
  /// **'Przegląd drużyny'**
  String get teamOverview_title;

  /// No description provided for @teamOverview_noLeague.
  ///
  /// In pl, this message translates to:
  /// **'Brak aktywnej ligi'**
  String get teamOverview_noLeague;

  /// No description provided for @teamOverview_invalidTeam.
  ///
  /// In pl, this message translates to:
  /// **'Drużyna gracza jest niedostępna'**
  String get teamOverview_invalidTeam;

  /// No description provided for @teamOverview_conference.
  ///
  /// In pl, this message translates to:
  /// **'Konferencja: {conference}'**
  String teamOverview_conference(Object conference);

  /// No description provided for @teamOverview_conferenceEurope.
  ///
  /// In pl, this message translates to:
  /// **'Europa'**
  String get teamOverview_conferenceEurope;

  /// No description provided for @teamOverview_conferenceRestOfWorld.
  ///
  /// In pl, this message translates to:
  /// **'Reszta świata'**
  String get teamOverview_conferenceRestOfWorld;

  /// No description provided for @teamOverview_standings.
  ///
  /// In pl, this message translates to:
  /// **'Tabela'**
  String get teamOverview_standings;

  /// No description provided for @teamOverview_record.
  ///
  /// In pl, this message translates to:
  /// **'Bilans'**
  String get teamOverview_record;

  /// No description provided for @teamOverview_conferenceRank.
  ///
  /// In pl, this message translates to:
  /// **'Miejsce w konferencji'**
  String get teamOverview_conferenceRank;

  /// No description provided for @teamOverview_overallRank.
  ///
  /// In pl, this message translates to:
  /// **'Miejsce w tabeli ogólnej'**
  String get teamOverview_overallRank;

  /// No description provided for @teamOverview_financials.
  ///
  /// In pl, this message translates to:
  /// **'Finanse'**
  String get teamOverview_financials;

  /// No description provided for @teamOverview_payroll.
  ///
  /// In pl, this message translates to:
  /// **'Payroll'**
  String get teamOverview_payroll;

  /// No description provided for @teamOverview_cap.
  ///
  /// In pl, this message translates to:
  /// **'Salary cap'**
  String get teamOverview_cap;

  /// No description provided for @teamOverview_capSpace.
  ///
  /// In pl, this message translates to:
  /// **'Wolne miejsce pod capem'**
  String get teamOverview_capSpace;

  /// No description provided for @teamOverview_teamState.
  ///
  /// In pl, this message translates to:
  /// **'Stan drużyny'**
  String get teamOverview_teamState;

  /// No description provided for @teamOverview_atmosphere.
  ///
  /// In pl, this message translates to:
  /// **'Atmosfera'**
  String get teamOverview_atmosphere;

  /// No description provided for @teamOverview_chemistry.
  ///
  /// In pl, this message translates to:
  /// **'Chemia'**
  String get teamOverview_chemistry;

  /// No description provided for @teamOverview_roster.
  ///
  /// In pl, this message translates to:
  /// **'Skład'**
  String get teamOverview_roster;

  /// No description provided for @teamOverview_staff.
  ///
  /// In pl, this message translates to:
  /// **'Sztab'**
  String get teamOverview_staff;

  /// No description provided for @teamOverview_nextAction.
  ///
  /// In pl, this message translates to:
  /// **'Następna akcja'**
  String get teamOverview_nextAction;

  /// No description provided for @teamOverview_action.
  ///
  /// In pl, this message translates to:
  /// **'Akcja'**
  String get teamOverview_action;

  /// No description provided for @teamOverview_nextMatch.
  ///
  /// In pl, this message translates to:
  /// **'Następny mecz'**
  String get teamOverview_nextMatch;

  /// No description provided for @teamOverview_noNextAction.
  ///
  /// In pl, this message translates to:
  /// **'Brak nadchodzącej akcji'**
  String get teamOverview_noNextAction;

  /// No description provided for @teamOverview_calendarPosition.
  ///
  /// In pl, this message translates to:
  /// **'Kalendarz'**
  String get teamOverview_calendarPosition;

  /// No description provided for @teamOverview_weekDay.
  ///
  /// In pl, this message translates to:
  /// **'Tydzień {week}, dzień {day}'**
  String teamOverview_weekDay(Object day, Object week);

  /// No description provided for @teamOverview_navigation.
  ///
  /// In pl, this message translates to:
  /// **'Otwórz ekrany'**
  String get teamOverview_navigation;

  /// No description provided for @teamOverview_viewSquad.
  ///
  /// In pl, this message translates to:
  /// **'Skład'**
  String get teamOverview_viewSquad;

  /// No description provided for @teamOverview_viewStats.
  ///
  /// In pl, this message translates to:
  /// **'Statystyki'**
  String get teamOverview_viewStats;

  /// No description provided for @teamOverview_viewStaff.
  ///
  /// In pl, this message translates to:
  /// **'Sztab'**
  String get teamOverview_viewStaff;

  /// No description provided for @teamOverview_viewFinance.
  ///
  /// In pl, this message translates to:
  /// **'Finanse'**
  String get teamOverview_viewFinance;

  /// No description provided for @teamOverview_viewSearch.
  ///
  /// In pl, this message translates to:
  /// **'Szukaj'**
  String get teamOverview_viewSearch;

  /// No description provided for @other_contracts.
  ///
  /// In pl, this message translates to:
  /// **'Kontrakty'**
  String get other_contracts;

  /// No description provided for @other_freeAgency.
  ///
  /// In pl, this message translates to:
  /// **'Wolni agenci'**
  String get other_freeAgency;

  /// No description provided for @other_prospects.
  ///
  /// In pl, this message translates to:
  /// **'Prospekci'**
  String get other_prospects;

  /// No description provided for @other_staff.
  ///
  /// In pl, this message translates to:
  /// **'Sztab'**
  String get other_staff;

  /// No description provided for @other_development.
  ///
  /// In pl, this message translates to:
  /// **'Rozwój'**
  String get other_development;

  /// No description provided for @other_playerStats.
  ///
  /// In pl, this message translates to:
  /// **'Statystyki zawodników'**
  String get other_playerStats;

  /// No description provided for @other_rewards.
  ///
  /// In pl, this message translates to:
  /// **'Nagrody'**
  String get other_rewards;

  /// No description provided for @other_search.
  ///
  /// In pl, this message translates to:
  /// **'Szukaj'**
  String get other_search;

  /// No description provided for @other_draftHistory.
  ///
  /// In pl, this message translates to:
  /// **'Historia draftu'**
  String get other_draftHistory;

  /// No description provided for @other_rankings.
  ///
  /// In pl, this message translates to:
  /// **'Rankingi'**
  String get other_rankings;

  /// No description provided for @other_watchlist.
  ///
  /// In pl, this message translates to:
  /// **'Lista obserwowanych'**
  String get other_watchlist;

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

  /// No description provided for @substitute_sheetEmpty.
  ///
  /// In pl, this message translates to:
  /// **'Brak dostępnych zawodników do zmiany'**
  String get substitute_sheetEmpty;

  /// No description provided for @standings_noLeague.
  ///
  /// In pl, this message translates to:
  /// **'Brak ligi'**
  String get standings_noLeague;

  /// No description provided for @standings_tabEast.
  ///
  /// In pl, this message translates to:
  /// **'Europa'**
  String get standings_tabEast;

  /// No description provided for @standings_tabWest.
  ///
  /// In pl, this message translates to:
  /// **'Reszta świata'**
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

  /// No description provided for @standings_tabPostseason.
  ///
  /// In pl, this message translates to:
  /// **'Faza pucharowa'**
  String get standings_tabPostseason;

  /// No description provided for @standings_playIn.
  ///
  /// In pl, this message translates to:
  /// **'Play-in'**
  String get standings_playIn;

  /// No description provided for @standings_playoffs.
  ///
  /// In pl, this message translates to:
  /// **'Playoffy'**
  String get standings_playoffs;

  /// No description provided for @standings_notStarted.
  ///
  /// In pl, this message translates to:
  /// **'Jeszcze się nie rozpoczęło'**
  String get standings_notStarted;

  /// No description provided for @standings_noPostseasonData.
  ///
  /// In pl, this message translates to:
  /// **'Brak danych fazy pucharowej'**
  String get standings_noPostseasonData;

  /// No description provided for @standings_match7v8.
  ///
  /// In pl, this message translates to:
  /// **'7. vs 8. miejsce'**
  String get standings_match7v8;

  /// No description provided for @standings_match9v10.
  ///
  /// In pl, this message translates to:
  /// **'9. vs 10. miejsce'**
  String get standings_match9v10;

  /// No description provided for @standings_playInFinal.
  ///
  /// In pl, this message translates to:
  /// **'Finał play-in'**
  String get standings_playInFinal;

  /// No description provided for @standings_quarterFinals.
  ///
  /// In pl, this message translates to:
  /// **'Ćwierćfinały'**
  String get standings_quarterFinals;

  /// No description provided for @standings_semiFinals.
  ///
  /// In pl, this message translates to:
  /// **'Półfinały'**
  String get standings_semiFinals;

  /// No description provided for @standings_conferenceFinals.
  ///
  /// In pl, this message translates to:
  /// **'Finał konferencji'**
  String get standings_conferenceFinals;

  /// No description provided for @standings_leagueFinal.
  ///
  /// In pl, this message translates to:
  /// **'Finał ligi'**
  String get standings_leagueFinal;

  /// No description provided for @standings_seriesInProgress.
  ///
  /// In pl, this message translates to:
  /// **'Seria w toku'**
  String get standings_seriesInProgress;

  /// No description provided for @standings_seriesWinner.
  ///
  /// In pl, this message translates to:
  /// **'Zwycięzca: {team}'**
  String standings_seriesWinner(String team);

  /// No description provided for @standings_champion.
  ///
  /// In pl, this message translates to:
  /// **'Mistrz: {team}'**
  String standings_champion(String team);

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

  /// No description provided for @finance_capWarning.
  ///
  /// In pl, this message translates to:
  /// **'Payroll przekracza salary cap'**
  String get finance_capWarning;

  /// No description provided for @finance_capHealthy.
  ///
  /// In pl, this message translates to:
  /// **'Payroll mieści się w salary cap'**
  String get finance_capHealthy;

  /// No description provided for @freeAgency_title.
  ///
  /// In pl, this message translates to:
  /// **'Wolna agentura'**
  String get freeAgency_title;

  /// No description provided for @freeAgency_noTeam.
  ///
  /// In pl, this message translates to:
  /// **'Brak drużyny gracza'**
  String get freeAgency_noTeam;

  /// No description provided for @freeAgency_search.
  ///
  /// In pl, this message translates to:
  /// **'Szukaj po nazwie'**
  String get freeAgency_search;

  /// No description provided for @freeAgency_position.
  ///
  /// In pl, this message translates to:
  /// **'Pozycja'**
  String get freeAgency_position;

  /// No description provided for @freeAgency_allPositions.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie pozycje'**
  String get freeAgency_allPositions;

  /// No description provided for @freeAgency_minOvr.
  ///
  /// In pl, this message translates to:
  /// **'Min. OVR'**
  String get freeAgency_minOvr;

  /// No description provided for @freeAgency_any.
  ///
  /// In pl, this message translates to:
  /// **'Dowolny'**
  String get freeAgency_any;

  /// No description provided for @freeAgency_sort.
  ///
  /// In pl, this message translates to:
  /// **'Sortowanie'**
  String get freeAgency_sort;

  /// No description provided for @freeAgency_sortOvr.
  ///
  /// In pl, this message translates to:
  /// **'Overall'**
  String get freeAgency_sortOvr;

  /// No description provided for @freeAgency_sortName.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa'**
  String get freeAgency_sortName;

  /// No description provided for @freeAgency_poolCount.
  ///
  /// In pl, this message translates to:
  /// **'Dostępni wolni agenci: {count}'**
  String freeAgency_poolCount(Object count);

  /// No description provided for @freeAgency_rosterUsage.
  ///
  /// In pl, this message translates to:
  /// **'Skład: {count}/30'**
  String freeAgency_rosterUsage(Object count);

  /// No description provided for @freeAgency_empty.
  ///
  /// In pl, this message translates to:
  /// **'Brak wolnych agentów pasujących do filtrów'**
  String get freeAgency_empty;

  /// No description provided for @freeAgency_playerSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'{position} · OVR {ovr} · Szacowana pensja: {salary}'**
  String freeAgency_playerSubtitle(Object ovr, Object position, Object salary);

  /// No description provided for @freeAgency_contractHeader.
  ///
  /// In pl, this message translates to:
  /// **'Oferta dla {name}'**
  String freeAgency_contractHeader(Object name);

  /// No description provided for @freeAgency_marketDemand.
  ///
  /// In pl, this message translates to:
  /// **'Szacowana pensja rynkowa: {salary}'**
  String freeAgency_marketDemand(Object salary);

  /// No description provided for @freeAgency_offerSalary.
  ///
  /// In pl, this message translates to:
  /// **'Oferta pensji'**
  String get freeAgency_offerSalary;

  /// No description provided for @freeAgency_offerYears.
  ///
  /// In pl, this message translates to:
  /// **'Lata kontraktu'**
  String get freeAgency_offerYears;

  /// No description provided for @freeAgency_submitOffer.
  ///
  /// In pl, this message translates to:
  /// **'Złóż ofertę'**
  String get freeAgency_submitOffer;

  /// No description provided for @freeAgency_selectPlayer.
  ///
  /// In pl, this message translates to:
  /// **'Najpierw wybierz wolnego agenta'**
  String get freeAgency_selectPlayer;

  /// No description provided for @freeAgency_invalidOffer.
  ///
  /// In pl, this message translates to:
  /// **'Podaj prawidłową pensję i 1–5 lat kontraktu'**
  String get freeAgency_invalidOffer;

  /// No description provided for @freeAgency_accepted.
  ///
  /// In pl, this message translates to:
  /// **'Oferta przyjęta, zawodnik podpisany'**
  String get freeAgency_accepted;

  /// No description provided for @freeAgency_rejected.
  ///
  /// In pl, this message translates to:
  /// **'Oferta odrzucona'**
  String get freeAgency_rejected;

  /// No description provided for @freeAgency_waiting.
  ///
  /// In pl, this message translates to:
  /// **'Zawodnik rozważa ofertę'**
  String get freeAgency_waiting;

  /// No description provided for @freeAgency_counter.
  ///
  /// In pl, this message translates to:
  /// **'Zawodnik złożył kontrofertę: {salary} × {years} lat'**
  String freeAgency_counter(Object salary, Object years);

  /// No description provided for @freeAgency_rosterFull.
  ///
  /// In pl, this message translates to:
  /// **'Skład jest pełny'**
  String get freeAgency_rosterFull;

  /// No description provided for @freeAgency_status.
  ///
  /// In pl, this message translates to:
  /// **'Status oferty'**
  String get freeAgency_status;

  /// No description provided for @freeAgency_capSpace.
  ///
  /// In pl, this message translates to:
  /// **'Wolne miejsce pod capem: {amount}'**
  String freeAgency_capSpace(Object amount);

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

  /// No description provided for @calendar_event_tradeWindowOpen.
  ///
  /// In pl, this message translates to:
  /// **'Otwarcie okna wymian'**
  String get calendar_event_tradeWindowOpen;

  /// No description provided for @calendar_event_contractExtensions.
  ///
  /// In pl, this message translates to:
  /// **'Przedłużenia kontraktów'**
  String get calendar_event_contractExtensions;

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

  /// No description provided for @trade_yourPick.
  ///
  /// In pl, this message translates to:
  /// **'Twój pick draftowy'**
  String get trade_yourPick;

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

  /// No description provided for @trade_theirPick.
  ///
  /// In pl, this message translates to:
  /// **'Ich pick draftowy'**
  String get trade_theirPick;

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

  /// No description provided for @dev_title.
  ///
  /// In pl, this message translates to:
  /// **'Rozwój'**
  String get dev_title;

  /// No description provided for @dev_tabPlayers.
  ///
  /// In pl, this message translates to:
  /// **'Zawodnicy'**
  String get dev_tabPlayers;

  /// No description provided for @dev_tabStaff.
  ///
  /// In pl, this message translates to:
  /// **'Sztab'**
  String get dev_tabStaff;

  /// No description provided for @dev_noTeam.
  ///
  /// In pl, this message translates to:
  /// **'Brak danych drużyny'**
  String get dev_noTeam;

  /// No description provided for @dev_noPlayers.
  ///
  /// In pl, this message translates to:
  /// **'Brak zawodników'**
  String get dev_noPlayers;

  /// No description provided for @dev_vacant.
  ///
  /// In pl, this message translates to:
  /// **'Wakancja'**
  String get dev_vacant;

  /// No description provided for @dev_colName.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa'**
  String get dev_colName;

  /// No description provided for @dev_colAge.
  ///
  /// In pl, this message translates to:
  /// **'Wiek'**
  String get dev_colAge;

  /// No description provided for @dev_colPotential.
  ///
  /// In pl, this message translates to:
  /// **'Pot.'**
  String get dev_colPotential;

  /// No description provided for @dev_colOvr.
  ///
  /// In pl, this message translates to:
  /// **'OVR'**
  String get dev_colOvr;

  /// No description provided for @dev_colChange.
  ///
  /// In pl, this message translates to:
  /// **'+/-'**
  String get dev_colChange;

  /// No description provided for @staffAttr_tactics.
  ///
  /// In pl, this message translates to:
  /// **'Taktyka'**
  String get staffAttr_tactics;

  /// No description provided for @staffAttr_motivation.
  ///
  /// In pl, this message translates to:
  /// **'Motywacja'**
  String get staffAttr_motivation;

  /// No description provided for @staffAttr_development.
  ///
  /// In pl, this message translates to:
  /// **'Rozwój'**
  String get staffAttr_development;

  /// No description provided for @staffAttr_mentoring.
  ///
  /// In pl, this message translates to:
  /// **'Mentoring'**
  String get staffAttr_mentoring;

  /// No description provided for @staffAttr_coverage.
  ///
  /// In pl, this message translates to:
  /// **'Zasięg'**
  String get staffAttr_coverage;

  /// No description provided for @staffAttr_evaluation.
  ///
  /// In pl, this message translates to:
  /// **'Ocena'**
  String get staffAttr_evaluation;

  /// No description provided for @staffAttr_rehabilitation.
  ///
  /// In pl, this message translates to:
  /// **'Rehabilitacja'**
  String get staffAttr_rehabilitation;

  /// No description provided for @staffAttr_regenaration.
  ///
  /// In pl, this message translates to:
  /// **'Regeneracja'**
  String get staffAttr_regenaration;

  /// No description provided for @staffAttr_prevention.
  ///
  /// In pl, this message translates to:
  /// **'Prewencja'**
  String get staffAttr_prevention;

  /// No description provided for @staffAttr_care.
  ///
  /// In pl, this message translates to:
  /// **'Opieka'**
  String get staffAttr_care;

  /// No description provided for @staffAttr_negotiation.
  ///
  /// In pl, this message translates to:
  /// **'Negocjacje'**
  String get staffAttr_negotiation;

  /// No description provided for @prospects_title.
  ///
  /// In pl, this message translates to:
  /// **'Prospekci'**
  String get prospects_title;

  /// No description provided for @prospects_name.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa'**
  String get prospects_name;

  /// No description provided for @prospects_nationality.
  ///
  /// In pl, this message translates to:
  /// **'Narodowość'**
  String get prospects_nationality;

  /// No description provided for @prospects_age.
  ///
  /// In pl, this message translates to:
  /// **'Wiek'**
  String get prospects_age;

  /// No description provided for @prospects_positionShort.
  ///
  /// In pl, this message translates to:
  /// **'Poz.'**
  String get prospects_positionShort;

  /// No description provided for @prospects_combine.
  ///
  /// In pl, this message translates to:
  /// **'Combine'**
  String get prospects_combine;

  /// No description provided for @prospects_grade.
  ///
  /// In pl, this message translates to:
  /// **'Ocena'**
  String get prospects_grade;

  /// No description provided for @prospects_stars.
  ///
  /// In pl, this message translates to:
  /// **'Gwiazdy'**
  String get prospects_stars;

  /// No description provided for @prospects_injuryShort.
  ///
  /// In pl, this message translates to:
  /// **'Kontuzje'**
  String get prospects_injuryShort;

  /// No description provided for @prospects_determinationShort.
  ///
  /// In pl, this message translates to:
  /// **'Det.'**
  String get prospects_determinationShort;

  /// No description provided for @prospects_slot.
  ///
  /// In pl, this message translates to:
  /// **'Slot'**
  String get prospects_slot;

  /// No description provided for @prospects_noDraftClass.
  ///
  /// In pl, this message translates to:
  /// **'Brak dostępnej klasy draftowej'**
  String get prospects_noDraftClass;

  /// No description provided for @prospects_empty.
  ///
  /// In pl, this message translates to:
  /// **'Brak prospektów pasujących do filtrów'**
  String get prospects_empty;

  /// No description provided for @prospects_search.
  ///
  /// In pl, this message translates to:
  /// **'Szukaj po nazwie'**
  String get prospects_search;

  /// No description provided for @prospects_position.
  ///
  /// In pl, this message translates to:
  /// **'Pozycja'**
  String get prospects_position;

  /// No description provided for @prospects_allPositions.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie pozycje'**
  String get prospects_allPositions;

  /// No description provided for @prospects_watchOnly.
  ///
  /// In pl, this message translates to:
  /// **'Tylko obserwowani'**
  String get prospects_watchOnly;

  /// No description provided for @prospects_sort.
  ///
  /// In pl, this message translates to:
  /// **'Sortowanie'**
  String get prospects_sort;

  /// No description provided for @prospects_sortName.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa'**
  String get prospects_sortName;

  /// No description provided for @prospects_sortOvr.
  ///
  /// In pl, this message translates to:
  /// **'Prognozowany OVR'**
  String get prospects_sortOvr;

  /// No description provided for @prospects_sortGrade.
  ///
  /// In pl, this message translates to:
  /// **'Ocena skauta'**
  String get prospects_sortGrade;

  /// No description provided for @prospects_sortPotential.
  ///
  /// In pl, this message translates to:
  /// **'Potencjał'**
  String get prospects_sortPotential;

  /// No description provided for @prospects_watchlist.
  ///
  /// In pl, this message translates to:
  /// **'Watchlista'**
  String get prospects_watchlist;

  /// No description provided for @prospects_watched.
  ///
  /// In pl, this message translates to:
  /// **'Obserwowany'**
  String get prospects_watched;

  /// No description provided for @prospects_saveWatchlist.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz watchlistę'**
  String get prospects_saveWatchlist;

  /// No description provided for @prospects_coverage.
  ///
  /// In pl, this message translates to:
  /// **'Coverage: {stars}★ · {selected}/{limit}'**
  String prospects_coverage(Object limit, Object selected, Object stars);

  /// No description provided for @prospects_scoutingData.
  ///
  /// In pl, this message translates to:
  /// **'Dane skautingowe'**
  String get prospects_scoutingData;

  /// No description provided for @prospects_noScouting.
  ///
  /// In pl, this message translates to:
  /// **'Brak danych skautingowych. Dodaj prospekta do watchlisty.'**
  String get prospects_noScouting;

  /// No description provided for @prospects_combineScore.
  ///
  /// In pl, this message translates to:
  /// **'Wynik Combine'**
  String get prospects_combineScore;

  /// No description provided for @prospects_scoutGrade.
  ///
  /// In pl, this message translates to:
  /// **'Ocena skauta'**
  String get prospects_scoutGrade;

  /// No description provided for @prospects_potential.
  ///
  /// In pl, this message translates to:
  /// **'Potencjał'**
  String get prospects_potential;

  /// No description provided for @prospects_injuryProne.
  ///
  /// In pl, this message translates to:
  /// **'Podatność na kontuzje'**
  String get prospects_injuryProne;

  /// No description provided for @prospects_determination.
  ///
  /// In pl, this message translates to:
  /// **'Determinacja'**
  String get prospects_determination;

  /// No description provided for @prospects_estimatedSlot.
  ///
  /// In pl, this message translates to:
  /// **'Szacowany slot'**
  String get prospects_estimatedSlot;

  /// No description provided for @prospects_unknown.
  ///
  /// In pl, this message translates to:
  /// **'Nieznane'**
  String get prospects_unknown;

  /// No description provided for @playerDetail_health.
  ///
  /// In pl, this message translates to:
  /// **'Zdrowie'**
  String get playerDetail_health;

  /// No description provided for @playerDetail_available.
  ///
  /// In pl, this message translates to:
  /// **'Dostępny'**
  String get playerDetail_available;

  /// No description provided for @playerDetail_injury.
  ///
  /// In pl, this message translates to:
  /// **'Kontuzja: {type}'**
  String playerDetail_injury(Object type);

  /// No description provided for @playerDetail_injuryDays.
  ///
  /// In pl, this message translates to:
  /// **'Pozostało dni: {days}'**
  String playerDetail_injuryDays(Object days);

  /// No description provided for @playerDetail_roleTeam.
  ///
  /// In pl, this message translates to:
  /// **'Rola i drużyna'**
  String get playerDetail_roleTeam;

  /// No description provided for @playerDetail_currentRole.
  ///
  /// In pl, this message translates to:
  /// **'Aktualna rola: {role}'**
  String playerDetail_currentRole(Object role);

  /// No description provided for @playerDetail_optimalRole.
  ///
  /// In pl, this message translates to:
  /// **'Optymalna rola: {role}'**
  String playerDetail_optimalRole(Object role);

  /// No description provided for @playerDetail_seasonsWithTeam.
  ///
  /// In pl, this message translates to:
  /// **'Sezony w drużynie: {seasons}'**
  String playerDetail_seasonsWithTeam(Object seasons);

  /// No description provided for @playerDetail_history.
  ///
  /// In pl, this message translates to:
  /// **'Historia sezonów'**
  String get playerDetail_history;

  /// No description provided for @playerDetail_career.
  ///
  /// In pl, this message translates to:
  /// **'Suma kariery'**
  String get playerDetail_career;

  /// No description provided for @playerDetail_season.
  ///
  /// In pl, this message translates to:
  /// **'Sezon'**
  String get playerDetail_season;

  /// No description provided for @playerDetail_appearances.
  ///
  /// In pl, this message translates to:
  /// **'Występy'**
  String get playerDetail_appearances;

  /// No description provided for @playerDetail_minutes.
  ///
  /// In pl, this message translates to:
  /// **'Minuty'**
  String get playerDetail_minutes;

  /// No description provided for @playerDetail_goals.
  ///
  /// In pl, this message translates to:
  /// **'Gole'**
  String get playerDetail_goals;

  /// No description provided for @playerDetail_assists.
  ///
  /// In pl, this message translates to:
  /// **'Asysty'**
  String get playerDetail_assists;

  /// No description provided for @playerDetail_rating.
  ///
  /// In pl, this message translates to:
  /// **'Ocena'**
  String get playerDetail_rating;

  /// No description provided for @playerDetail_noHistory.
  ///
  /// In pl, this message translates to:
  /// **'Brak statystyk sezonowych'**
  String get playerDetail_noHistory;

  /// No description provided for @squad_filters.
  ///
  /// In pl, this message translates to:
  /// **'Filtry składu'**
  String get squad_filters;

  /// No description provided for @squad_search.
  ///
  /// In pl, this message translates to:
  /// **'Szukaj po nazwie'**
  String get squad_search;

  /// No description provided for @squad_position.
  ///
  /// In pl, this message translates to:
  /// **'Pozycja'**
  String get squad_position;

  /// No description provided for @squad_allPositions.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie pozycje'**
  String get squad_allPositions;

  /// No description provided for @squad_zone.
  ///
  /// In pl, this message translates to:
  /// **'Strefa'**
  String get squad_zone;

  /// No description provided for @squad_allZones.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie strefy'**
  String get squad_allZones;

  /// No description provided for @squad_availability.
  ///
  /// In pl, this message translates to:
  /// **'Dostępność'**
  String get squad_availability;

  /// No description provided for @squad_allPlayers.
  ///
  /// In pl, this message translates to:
  /// **'Wszyscy zawodnicy'**
  String get squad_allPlayers;

  /// No description provided for @squad_available.
  ///
  /// In pl, this message translates to:
  /// **'Dostępni'**
  String get squad_available;

  /// No description provided for @squad_injuredOnly.
  ///
  /// In pl, this message translates to:
  /// **'Kontuzjowani'**
  String get squad_injuredOnly;

  /// No description provided for @squad_minOvr.
  ///
  /// In pl, this message translates to:
  /// **'Min. OVR'**
  String get squad_minOvr;

  /// No description provided for @squad_minForm.
  ///
  /// In pl, this message translates to:
  /// **'Min. forma'**
  String get squad_minForm;

  /// No description provided for @squad_any.
  ///
  /// In pl, this message translates to:
  /// **'Dowolna'**
  String get squad_any;

  /// No description provided for @squad_clearFilters.
  ///
  /// In pl, this message translates to:
  /// **'Wyczyść filtry'**
  String get squad_clearFilters;

  /// No description provided for @squad_noPlayers.
  ///
  /// In pl, this message translates to:
  /// **'Brak zawodników pasujących do filtrów'**
  String get squad_noPlayers;

  /// No description provided for @squad_matchday.
  ///
  /// In pl, this message translates to:
  /// **'Skład meczowy'**
  String get squad_matchday;

  /// No description provided for @squad_healthy.
  ///
  /// In pl, this message translates to:
  /// **'Zdrowi: {count}'**
  String squad_healthy(Object count);

  /// No description provided for @squad_belowXi.
  ///
  /// In pl, this message translates to:
  /// **'Dostępnych jest mniej niż 11 zdrowych zawodników'**
  String get squad_belowXi;

  /// No description provided for @squad_xiCount.
  ///
  /// In pl, this message translates to:
  /// **'XI: {count}'**
  String squad_xiCount(Object count);

  /// No description provided for @squad_benchCount.
  ///
  /// In pl, this message translates to:
  /// **'Ławka: {count}'**
  String squad_benchCount(Object count);

  /// No description provided for @squad_reserveCount.
  ///
  /// In pl, this message translates to:
  /// **'Rezerwy: {count}'**
  String squad_reserveCount(Object count);

  /// No description provided for @draftHistory_title.
  ///
  /// In pl, this message translates to:
  /// **'Historia draftu'**
  String get draftHistory_title;

  /// No description provided for @draftHistory_noDraftData.
  ///
  /// In pl, this message translates to:
  /// **'Brak danych draftu'**
  String get draftHistory_noDraftData;

  /// No description provided for @draftHistory_currentDraft.
  ///
  /// In pl, this message translates to:
  /// **'Bieżący draft'**
  String get draftHistory_currentDraft;

  /// No description provided for @draftHistory_season.
  ///
  /// In pl, this message translates to:
  /// **'Sezon {year}'**
  String draftHistory_season(Object year);

  /// No description provided for @draftHistory_pick.
  ///
  /// In pl, this message translates to:
  /// **'Pick {number}'**
  String draftHistory_pick(Object number);

  /// No description provided for @draftHistory_round.
  ///
  /// In pl, this message translates to:
  /// **'Runda {round}'**
  String draftHistory_round(Object round);

  /// No description provided for @draftHistory_team.
  ///
  /// In pl, this message translates to:
  /// **'Drużyna'**
  String get draftHistory_team;

  /// No description provided for @draftHistory_originalTeam.
  ///
  /// In pl, this message translates to:
  /// **'Pierwotna drużyna'**
  String get draftHistory_originalTeam;

  /// No description provided for @draftHistory_player.
  ///
  /// In pl, this message translates to:
  /// **'Zawodnik'**
  String get draftHistory_player;

  /// No description provided for @draftHistory_noPicks.
  ///
  /// In pl, this message translates to:
  /// **'Brak zakończonych wyborów'**
  String get draftHistory_noPicks;

  /// No description provided for @draftHistory_lottery.
  ///
  /// In pl, this message translates to:
  /// **'Wyniki loterii'**
  String get draftHistory_lottery;

  /// No description provided for @draftHistory_noLottery.
  ///
  /// In pl, this message translates to:
  /// **'Brak wyników loterii dla tego sezonu'**
  String get draftHistory_noLottery;

  /// No description provided for @rankings_title.
  ///
  /// In pl, this message translates to:
  /// **'Rankingi'**
  String get rankings_title;

  /// No description provided for @rankings_power.
  ///
  /// In pl, this message translates to:
  /// **'Ranking siły'**
  String get rankings_power;

  /// No description provided for @rankings_expected.
  ///
  /// In pl, this message translates to:
  /// **'Przewidywane miejsce'**
  String get rankings_expected;

  /// No description provided for @rankings_assets.
  ///
  /// In pl, this message translates to:
  /// **'Aktywa transferowe'**
  String get rankings_assets;

  /// No description provided for @rankings_noStrength.
  ///
  /// In pl, this message translates to:
  /// **'Ranking siły nie został jeszcze obliczony'**
  String get rankings_noStrength;

  /// No description provided for @rankings_rank.
  ///
  /// In pl, this message translates to:
  /// **'Miejsce'**
  String get rankings_rank;

  /// No description provided for @rankings_team.
  ///
  /// In pl, this message translates to:
  /// **'Drużyna'**
  String get rankings_team;

  /// No description provided for @rankings_powerValue.
  ///
  /// In pl, this message translates to:
  /// **'Siła'**
  String get rankings_powerValue;

  /// No description provided for @rankings_status.
  ///
  /// In pl, this message translates to:
  /// **'Status'**
  String get rankings_status;

  /// No description provided for @rankings_updated.
  ///
  /// In pl, this message translates to:
  /// **'Aktualizacja: tydzień {week}, dzień {day}'**
  String rankings_updated(Object day, Object week);

  /// No description provided for @rankings_expectedDisclaimer.
  ///
  /// In pl, this message translates to:
  /// **'Przewidywane miejsce odzwierciedla siłę składu, a nie symulację końcowej tabeli.'**
  String get rankings_expectedDisclaimer;

  /// No description provided for @rankings_assetValue.
  ///
  /// In pl, this message translates to:
  /// **'Wartość'**
  String get rankings_assetValue;

  /// No description provided for @rankings_assetType.
  ///
  /// In pl, this message translates to:
  /// **'Typ'**
  String get rankings_assetType;

  /// No description provided for @rankings_owner.
  ///
  /// In pl, this message translates to:
  /// **'Właściciel'**
  String get rankings_owner;

  /// No description provided for @rankings_noAssets.
  ///
  /// In pl, this message translates to:
  /// **'Brak dostępnych aktywów transferowych'**
  String get rankings_noAssets;

  /// No description provided for @rankings_playerAsset.
  ///
  /// In pl, this message translates to:
  /// **'Zawodnik'**
  String get rankings_playerAsset;

  /// No description provided for @rankings_pickAsset.
  ///
  /// In pl, this message translates to:
  /// **'Pick draftowy'**
  String get rankings_pickAsset;

  /// No description provided for @rankings_statusRebuild.
  ///
  /// In pl, this message translates to:
  /// **'Przebudowa'**
  String get rankings_statusRebuild;

  /// No description provided for @rankings_statusRetool.
  ///
  /// In pl, this message translates to:
  /// **'Retool'**
  String get rankings_statusRetool;

  /// No description provided for @rankings_statusPretender.
  ///
  /// In pl, this message translates to:
  /// **'Pretendent'**
  String get rankings_statusPretender;

  /// No description provided for @rankings_statusContender.
  ///
  /// In pl, this message translates to:
  /// **'Faworyt'**
  String get rankings_statusContender;

  /// No description provided for @rankings_statusElite.
  ///
  /// In pl, this message translates to:
  /// **'Elita'**
  String get rankings_statusElite;

  /// No description provided for @stats_title.
  ///
  /// In pl, this message translates to:
  /// **'Statystyki'**
  String get stats_title;

  /// No description provided for @stats_players.
  ///
  /// In pl, this message translates to:
  /// **'Statystyki zawodników'**
  String get stats_players;

  /// No description provided for @stats_teamOverview.
  ///
  /// In pl, this message translates to:
  /// **'Przegląd drużyn'**
  String get stats_teamOverview;

  /// No description provided for @stats_noStats.
  ///
  /// In pl, this message translates to:
  /// **'Brak zapisanych statystyk meczowych'**
  String get stats_noStats;

  /// No description provided for @stats_search.
  ///
  /// In pl, this message translates to:
  /// **'Szukaj zawodnika'**
  String get stats_search;

  /// No description provided for @stats_sort.
  ///
  /// In pl, this message translates to:
  /// **'Sortowanie'**
  String get stats_sort;

  /// No description provided for @stats_sortOvr.
  ///
  /// In pl, this message translates to:
  /// **'OVR'**
  String get stats_sortOvr;

  /// No description provided for @stats_sortGoals.
  ///
  /// In pl, this message translates to:
  /// **'Gole'**
  String get stats_sortGoals;

  /// No description provided for @stats_sortAssists.
  ///
  /// In pl, this message translates to:
  /// **'Asysty'**
  String get stats_sortAssists;

  /// No description provided for @stats_sortRating.
  ///
  /// In pl, this message translates to:
  /// **'Ocena'**
  String get stats_sortRating;

  /// No description provided for @stats_player.
  ///
  /// In pl, this message translates to:
  /// **'Zawodnik'**
  String get stats_player;

  /// No description provided for @stats_team.
  ///
  /// In pl, this message translates to:
  /// **'Drużyna'**
  String get stats_team;

  /// No description provided for @stats_appearances.
  ///
  /// In pl, this message translates to:
  /// **'Występy'**
  String get stats_appearances;

  /// No description provided for @stats_minutes.
  ///
  /// In pl, this message translates to:
  /// **'Minuty'**
  String get stats_minutes;

  /// No description provided for @stats_goals.
  ///
  /// In pl, this message translates to:
  /// **'Gole'**
  String get stats_goals;

  /// No description provided for @stats_assists.
  ///
  /// In pl, this message translates to:
  /// **'Asysty'**
  String get stats_assists;

  /// No description provided for @stats_rating.
  ///
  /// In pl, this message translates to:
  /// **'Ocena'**
  String get stats_rating;

  /// No description provided for @stats_record.
  ///
  /// In pl, this message translates to:
  /// **'Bilans'**
  String get stats_record;

  /// No description provided for @stats_roster.
  ///
  /// In pl, this message translates to:
  /// **'Skład'**
  String get stats_roster;

  /// No description provided for @stats_averageOvr.
  ///
  /// In pl, this message translates to:
  /// **'Średni OVR'**
  String get stats_averageOvr;

  /// No description provided for @stats_injured.
  ///
  /// In pl, this message translates to:
  /// **'Kontuzjowani'**
  String get stats_injured;

  /// No description provided for @stats_payroll.
  ///
  /// In pl, this message translates to:
  /// **'Payroll'**
  String get stats_payroll;

  /// No description provided for @stats_atmosphere.
  ///
  /// In pl, this message translates to:
  /// **'Atmosfera'**
  String get stats_atmosphere;

  /// No description provided for @stats_chemistry.
  ///
  /// In pl, this message translates to:
  /// **'Chemia'**
  String get stats_chemistry;

  /// No description provided for @stats_status.
  ///
  /// In pl, this message translates to:
  /// **'Status'**
  String get stats_status;

  /// No description provided for @stats_noStandings.
  ///
  /// In pl, this message translates to:
  /// **'Brak dostępnej tabeli'**
  String get stats_noStandings;

  /// No description provided for @rewards_title.
  ///
  /// In pl, this message translates to:
  /// **'Nagrody'**
  String get rewards_title;

  /// No description provided for @rewards_noAwards.
  ///
  /// In pl, this message translates to:
  /// **'Nagrody nie zostały jeszcze obliczone'**
  String get rewards_noAwards;

  /// No description provided for @rewards_notAwarded.
  ///
  /// In pl, this message translates to:
  /// **'Nie przyznano'**
  String get rewards_notAwarded;

  /// No description provided for @rewards_mvp.
  ///
  /// In pl, this message translates to:
  /// **'MVP'**
  String get rewards_mvp;

  /// No description provided for @rewards_roty.
  ///
  /// In pl, this message translates to:
  /// **'Debiutant roku'**
  String get rewards_roty;

  /// No description provided for @rewards_dpoy.
  ///
  /// In pl, this message translates to:
  /// **'Obrońca roku'**
  String get rewards_dpoy;

  /// No description provided for @rewards_topScorer.
  ///
  /// In pl, this message translates to:
  /// **'Najlepszy strzelec'**
  String get rewards_topScorer;

  /// No description provided for @rewards_topAssist.
  ///
  /// In pl, this message translates to:
  /// **'Najlepszy asystent'**
  String get rewards_topAssist;

  /// No description provided for @rewards_bestGk.
  ///
  /// In pl, this message translates to:
  /// **'Najlepszy bramkarz'**
  String get rewards_bestGk;

  /// No description provided for @rewards_coachOfYear.
  ///
  /// In pl, this message translates to:
  /// **'Trener roku'**
  String get rewards_coachOfYear;

  /// No description provided for @rewards_champion.
  ///
  /// In pl, this message translates to:
  /// **'Mistrz'**
  String get rewards_champion;

  /// No description provided for @rewards_teamOfSeason.
  ///
  /// In pl, this message translates to:
  /// **'Drużyna sezonu'**
  String get rewards_teamOfSeason;

  /// No description provided for @search_title.
  ///
  /// In pl, this message translates to:
  /// **'Wyszukiwanie'**
  String get search_title;

  /// No description provided for @search_hint.
  ///
  /// In pl, this message translates to:
  /// **'Szukaj drużyn, zawodników i prospektów'**
  String get search_hint;

  /// No description provided for @search_allTypes.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie typy'**
  String get search_allTypes;

  /// No description provided for @search_players.
  ///
  /// In pl, this message translates to:
  /// **'Zawodnicy'**
  String get search_players;

  /// No description provided for @search_teams.
  ///
  /// In pl, this message translates to:
  /// **'Drużyny'**
  String get search_teams;

  /// No description provided for @search_prospects.
  ///
  /// In pl, this message translates to:
  /// **'Prospekci'**
  String get search_prospects;

  /// No description provided for @search_freeAgents.
  ///
  /// In pl, this message translates to:
  /// **'Wolni agenci'**
  String get search_freeAgents;

  /// No description provided for @search_noResults.
  ///
  /// In pl, this message translates to:
  /// **'Brak wyników'**
  String get search_noResults;

  /// No description provided for @search_tradeAction.
  ///
  /// In pl, this message translates to:
  /// **'Wymień'**
  String get search_tradeAction;

  /// No description provided for @search_teamResult.
  ///
  /// In pl, this message translates to:
  /// **'Drużyna · {conference}'**
  String search_teamResult(Object conference);

  /// No description provided for @search_playerResult.
  ///
  /// In pl, this message translates to:
  /// **'Zawodnik · {team} · {position}'**
  String search_playerResult(Object position, Object team);

  /// No description provided for @search_prospectResult.
  ///
  /// In pl, this message translates to:
  /// **'Prospekt · {position} · wiek {age}'**
  String search_prospectResult(Object age, Object position);

  /// No description provided for @search_freeAgentResult.
  ///
  /// In pl, this message translates to:
  /// **'Wolny agent · {position} · OVR {ovr}'**
  String search_freeAgentResult(Object ovr, Object position);
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
