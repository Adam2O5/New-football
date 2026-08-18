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

  /// No description provided for @matchEvent_foul.
  ///
  /// In pl, this message translates to:
  /// **'Faul'**
  String get matchEvent_foul;

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

  /// No description provided for @notificationLevel_auto.
  ///
  /// In pl, this message translates to:
  /// **'Automatyczne'**
  String get notificationLevel_auto;

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

  /// No description provided for @tradeHistory_title.
  ///
  /// In pl, this message translates to:
  /// **'Historia wymian'**
  String get tradeHistory_title;

  /// No description provided for @tradeHistory_noLeague.
  ///
  /// In pl, this message translates to:
  /// **'Brak aktywnej ligi'**
  String get tradeHistory_noLeague;

  /// No description provided for @tradeHistory_empty.
  ///
  /// In pl, this message translates to:
  /// **'Brak zapisanej historii wymian.'**
  String get tradeHistory_empty;

  /// No description provided for @tradeHistory_noMatches.
  ///
  /// In pl, this message translates to:
  /// **'Brak wymian dla wybranego filtra.'**
  String get tradeHistory_noMatches;

  /// No description provided for @tradeHistory_filter.
  ///
  /// In pl, this message translates to:
  /// **'Filtr wyniku'**
  String get tradeHistory_filter;

  /// No description provided for @tradeHistory_allOutcomes.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie wyniki'**
  String get tradeHistory_allOutcomes;

  /// No description provided for @tradeHistory_outcomeAccepted.
  ///
  /// In pl, this message translates to:
  /// **'Zaakceptowana'**
  String get tradeHistory_outcomeAccepted;

  /// No description provided for @tradeHistory_outcomeRejected.
  ///
  /// In pl, this message translates to:
  /// **'Odrzucona'**
  String get tradeHistory_outcomeRejected;

  /// No description provided for @tradeHistory_outcomeHardRejected.
  ///
  /// In pl, this message translates to:
  /// **'Zablokowana'**
  String get tradeHistory_outcomeHardRejected;

  /// No description provided for @tradeHistory_outcomeExpired.
  ///
  /// In pl, this message translates to:
  /// **'Wygasła'**
  String get tradeHistory_outcomeExpired;

  /// No description provided for @tradeHistory_outcomeNtcRefused.
  ///
  /// In pl, this message translates to:
  /// **'Odrzucona przez NTC'**
  String get tradeHistory_outcomeNtcRefused;

  /// No description provided for @tradeHistory_outcomeCancelled.
  ///
  /// In pl, this message translates to:
  /// **'Anulowana'**
  String get tradeHistory_outcomeCancelled;

  /// No description provided for @tradeHistory_date.
  ///
  /// In pl, this message translates to:
  /// **'Sezon {season}, tydzień {week}, dzień {day}'**
  String tradeHistory_date(int season, int week, int day);

  /// No description provided for @tradeHistory_round.
  ///
  /// In pl, this message translates to:
  /// **'Runda {round}'**
  String tradeHistory_round(int round);

  /// No description provided for @tradeHistory_reason.
  ///
  /// In pl, this message translates to:
  /// **'Powód'**
  String get tradeHistory_reason;

  /// No description provided for @tradeHistory_ntcProbability.
  ///
  /// In pl, this message translates to:
  /// **'Prawdopodobieństwo zgody NTC'**
  String get tradeHistory_ntcProbability;

  /// No description provided for @tradeHistory_sentBy.
  ///
  /// In pl, this message translates to:
  /// **'Aktywa od {team}'**
  String tradeHistory_sentBy(String team);

  /// No description provided for @tradeHistory_noAssets.
  ///
  /// In pl, this message translates to:
  /// **'Brak aktywów'**
  String get tradeHistory_noAssets;

  /// No description provided for @tradeHistory_player.
  ///
  /// In pl, this message translates to:
  /// **'Zawodnik: {name}'**
  String tradeHistory_player(String name);

  /// No description provided for @tradeHistory_pick.
  ///
  /// In pl, this message translates to:
  /// **'Pick: {year}, runda {round}'**
  String tradeHistory_pick(int year, int round);

  /// No description provided for @tradeHistory_rights.
  ///
  /// In pl, this message translates to:
  /// **'Prawa draftowe: {name}'**
  String tradeHistory_rights(String name);

  /// No description provided for @tradeHistory_unknownAsset.
  ///
  /// In pl, this message translates to:
  /// **'Aktyw: {type}'**
  String tradeHistory_unknownAsset(String type);

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

  /// No description provided for @teamOverview_atmosphereMult.
  ///
  /// In pl, this message translates to:
  /// **'Mnożnik atmosfery'**
  String get teamOverview_atmosphereMult;

  /// No description provided for @teamOverview_chemistryMult.
  ///
  /// In pl, this message translates to:
  /// **'Mnożnik chemii'**
  String get teamOverview_chemistryMult;

  /// No description provided for @teamOverview_teamPower.
  ///
  /// In pl, this message translates to:
  /// **'Siła drużyny'**
  String get teamOverview_teamPower;

  /// No description provided for @teamOverview_expectedRank.
  ///
  /// In pl, this message translates to:
  /// **'Oczekiwane miejsce'**
  String get teamOverview_expectedRank;

  /// No description provided for @teamOverview_status.
  ///
  /// In pl, this message translates to:
  /// **'Status'**
  String get teamOverview_status;

  /// No description provided for @teamOverview_weeklyHistory.
  ///
  /// In pl, this message translates to:
  /// **'Historia tygodniowa'**
  String get teamOverview_weeklyHistory;

  /// No description provided for @teamOverview_noHistory.
  ///
  /// In pl, this message translates to:
  /// **'Brak zapisanej historii'**
  String get teamOverview_noHistory;

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
  /// **'Oferta przyjęta — potwierdź finalizację'**
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

  /// No description provided for @market_status.
  ///
  /// In pl, this message translates to:
  /// **'Rynek kontraktów'**
  String get market_status;

  /// No description provided for @market_negotiations.
  ///
  /// In pl, this message translates to:
  /// **'Negocjacje'**
  String get market_negotiations;

  /// No description provided for @market_noNegotiations.
  ///
  /// In pl, this message translates to:
  /// **'Brak zapisanych negocjacji.'**
  String get market_noNegotiations;

  /// No description provided for @market_offerPreview.
  ///
  /// In pl, this message translates to:
  /// **'Podgląd oferty'**
  String get market_offerPreview;

  /// No description provided for @market_currentOffer.
  ///
  /// In pl, this message translates to:
  /// **'Bieżąca oferta'**
  String get market_currentOffer;

  /// No description provided for @market_advanceHour.
  ///
  /// In pl, this message translates to:
  /// **'Przejdź o godzinę'**
  String get market_advanceHour;

  /// No description provided for @market_hourAdvanced.
  ///
  /// In pl, this message translates to:
  /// **'Przesunięto rynek o godzinę.'**
  String get market_hourAdvanced;

  /// No description provided for @market_statusActive.
  ///
  /// In pl, this message translates to:
  /// **'Aktywna'**
  String get market_statusActive;

  /// No description provided for @market_statusCounter.
  ///
  /// In pl, this message translates to:
  /// **'Oczekuje na odpowiedź na kontrofertę'**
  String get market_statusCounter;

  /// No description provided for @market_statusHardRejected.
  ///
  /// In pl, this message translates to:
  /// **'Odrzucona i zablokowana'**
  String get market_statusHardRejected;

  /// No description provided for @market_statusCompleted.
  ///
  /// In pl, this message translates to:
  /// **'Zakończona'**
  String get market_statusCompleted;

  /// No description provided for @market_statusCancelled.
  ///
  /// In pl, this message translates to:
  /// **'Anulowana'**
  String get market_statusCancelled;

  /// No description provided for @market_statusExpired.
  ///
  /// In pl, this message translates to:
  /// **'Termin negocjacji minął'**
  String get market_statusExpired;

  /// No description provided for @market_closed.
  ///
  /// In pl, this message translates to:
  /// **'Zamknięty'**
  String get market_closed;

  /// No description provided for @market_extensions.
  ///
  /// In pl, this message translates to:
  /// **'Przedłużenia'**
  String get market_extensions;

  /// No description provided for @market_phaseI.
  ///
  /// In pl, this message translates to:
  /// **'Wolna agentura — faza I'**
  String get market_phaseI;

  /// No description provided for @market_phaseII.
  ///
  /// In pl, this message translates to:
  /// **'Wolna agentura — faza II'**
  String get market_phaseII;

  /// No description provided for @market_date.
  ///
  /// In pl, this message translates to:
  /// **'Tydzień {week} · dzień {day}'**
  String market_date(Object day, Object week);

  /// No description provided for @market_hour.
  ///
  /// In pl, this message translates to:
  /// **'Godzina ofert: {hour}/{total}'**
  String market_hour(Object hour, Object total);

  /// No description provided for @market_round.
  ///
  /// In pl, this message translates to:
  /// **'Runda {round}'**
  String market_round(Object round);

  /// No description provided for @market_deadline.
  ///
  /// In pl, this message translates to:
  /// **'Termin: tydz. {week}, dzień {day}, godz. {hour}'**
  String market_deadline(Object day, Object hour, Object week);

  /// No description provided for @market_score.
  ///
  /// In pl, this message translates to:
  /// **'Wynik oferty: {score}'**
  String market_score(Object score);

  /// No description provided for @market_expectedSalary.
  ///
  /// In pl, this message translates to:
  /// **'Oczekiwana pensja: {salary}'**
  String market_expectedSalary(Object salary);

  /// No description provided for @market_expectedLength.
  ///
  /// In pl, this message translates to:
  /// **'Oczekiwana długość: {years} lat'**
  String market_expectedLength(Object years);

  /// No description provided for @market_staffCandidates.
  ///
  /// In pl, this message translates to:
  /// **'Dostępny sztab'**
  String get market_staffCandidates;

  /// No description provided for @market_staffOffer.
  ///
  /// In pl, this message translates to:
  /// **'Złóż ofertę sztabowi'**
  String get market_staffOffer;

  /// No description provided for @market_qo.
  ///
  /// In pl, this message translates to:
  /// **'Qualifying Offers'**
  String get market_qo;

  /// No description provided for @market_qoEligible.
  ///
  /// In pl, this message translates to:
  /// **'Kandydaci do QO'**
  String get market_qoEligible;

  /// No description provided for @market_qoSubmitted.
  ///
  /// In pl, this message translates to:
  /// **'Aktywne QO'**
  String get market_qoSubmitted;

  /// No description provided for @market_qoMinimum.
  ///
  /// In pl, this message translates to:
  /// **'Minimalna QO: {salary}'**
  String market_qoMinimum(Object salary);

  /// No description provided for @market_offerSheetFrom.
  ///
  /// In pl, this message translates to:
  /// **'Oferta od: {team}'**
  String market_offerSheetFrom(Object team);

  /// No description provided for @market_submitQO.
  ///
  /// In pl, this message translates to:
  /// **'Złóż QO'**
  String get market_submitQO;

  /// No description provided for @market_offerSheets.
  ///
  /// In pl, this message translates to:
  /// **'Offer sheets RFA'**
  String get market_offerSheets;

  /// No description provided for @market_match.
  ///
  /// In pl, this message translates to:
  /// **'Wyrównaj'**
  String get market_match;

  /// No description provided for @market_release.
  ///
  /// In pl, this message translates to:
  /// **'Odrzuć'**
  String get market_release;

  /// No description provided for @market_draftedRights.
  ///
  /// In pl, this message translates to:
  /// **'Prawa do draftowanych'**
  String get market_draftedRights;

  /// No description provided for @market_signRights.
  ///
  /// In pl, this message translates to:
  /// **'Podpisz prawa'**
  String get market_signRights;

  /// No description provided for @market_rosterFull.
  ///
  /// In pl, this message translates to:
  /// **'Brak miejsca w rosterze'**
  String get market_rosterFull;

  /// No description provided for @market_noWindow.
  ///
  /// In pl, this message translates to:
  /// **'Dziś nie jest otwarte żadne okno kontraktowe.'**
  String get market_noWindow;

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

  /// No description provided for @inbox_tabInbox.
  ///
  /// In pl, this message translates to:
  /// **'Skrzynka'**
  String get inbox_tabInbox;

  /// No description provided for @inbox_tabArchive.
  ///
  /// In pl, this message translates to:
  /// **'Archiwum'**
  String get inbox_tabArchive;

  /// No description provided for @inbox_filterAll.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie'**
  String get inbox_filterAll;

  /// No description provided for @inbox_sectionUrgent.
  ///
  /// In pl, this message translates to:
  /// **'Pilne'**
  String get inbox_sectionUrgent;

  /// No description provided for @inbox_sectionUnread.
  ///
  /// In pl, this message translates to:
  /// **'Nieprzeczytane'**
  String get inbox_sectionUnread;

  /// No description provided for @inbox_sectionRead.
  ///
  /// In pl, this message translates to:
  /// **'Przeczytane'**
  String get inbox_sectionRead;

  /// No description provided for @inbox_emptyArchive.
  ///
  /// In pl, this message translates to:
  /// **'Archiwum jest puste'**
  String get inbox_emptyArchive;

  /// No description provided for @inbox_detailTitle.
  ///
  /// In pl, this message translates to:
  /// **'Szczegóły wiadomości'**
  String get inbox_detailTitle;

  /// No description provided for @inbox_bodyFallback.
  ///
  /// In pl, this message translates to:
  /// **'Nowa informacja dotycząca: {type}.'**
  String inbox_bodyFallback(String type);

  /// No description provided for @inbox_metadata.
  ///
  /// In pl, this message translates to:
  /// **'Tydzień {week} · dzień {day} · {domain}'**
  String inbox_metadata(int week, int day, String domain);

  /// No description provided for @inbox_deadline.
  ///
  /// In pl, this message translates to:
  /// **'Termin: {value}'**
  String inbox_deadline(String value);

  /// No description provided for @inbox_defaultOnExpiry.
  ///
  /// In pl, this message translates to:
  /// **'Po terminie: {value}'**
  String inbox_defaultOnExpiry(String value);

  /// No description provided for @inbox_decisionOptions.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz opcję'**
  String get inbox_decisionOptions;

  /// No description provided for @inbox_actions.
  ///
  /// In pl, this message translates to:
  /// **'Akcje'**
  String get inbox_actions;

  /// No description provided for @inbox_acknowledge.
  ///
  /// In pl, this message translates to:
  /// **'Potwierdź'**
  String get inbox_acknowledge;

  /// No description provided for @inbox_close.
  ///
  /// In pl, this message translates to:
  /// **'Zamknij'**
  String get inbox_close;

  /// No description provided for @inbox_digestMembers.
  ///
  /// In pl, this message translates to:
  /// **'Wiadomości składowe ({count})'**
  String inbox_digestMembers(int count);

  /// No description provided for @inbox_actionAccept.
  ///
  /// In pl, this message translates to:
  /// **'Akceptuj'**
  String get inbox_actionAccept;

  /// No description provided for @inbox_actionDecline.
  ///
  /// In pl, this message translates to:
  /// **'Odrzuć'**
  String get inbox_actionDecline;

  /// No description provided for @inbox_actionCounter.
  ///
  /// In pl, this message translates to:
  /// **'Kontroferta'**
  String get inbox_actionCounter;

  /// No description provided for @inbox_actionReject.
  ///
  /// In pl, this message translates to:
  /// **'Odrzuć'**
  String get inbox_actionReject;

  /// No description provided for @inbox_actionOpen.
  ///
  /// In pl, this message translates to:
  /// **'Otwórz'**
  String get inbox_actionOpen;

  /// No description provided for @inbox_actionFallback.
  ///
  /// In pl, this message translates to:
  /// **'Wykonaj akcję'**
  String get inbox_actionFallback;

  /// No description provided for @inbox_settingsDomain.
  ///
  /// In pl, this message translates to:
  /// **'Ustawienia domen'**
  String get inbox_settingsDomain;

  /// No description provided for @inbox_settingsType.
  ///
  /// In pl, this message translates to:
  /// **'Ustawienia typów'**
  String get inbox_settingsType;

  /// No description provided for @inbox_settingsDecisionMuted.
  ///
  /// In pl, this message translates to:
  /// **'Typów decyzyjnych nie można wyciszyć.'**
  String get inbox_settingsDecisionMuted;

  /// No description provided for @inbox_settingsDomainDecisionMuted.
  ///
  /// In pl, this message translates to:
  /// **'Domena zawiera decyzje i nie może być wyciszona.'**
  String get inbox_settingsDomainDecisionMuted;

  /// No description provided for @messageDomain_matchday.
  ///
  /// In pl, this message translates to:
  /// **'Mecze'**
  String get messageDomain_matchday;

  /// No description provided for @messageDomain_health.
  ///
  /// In pl, this message translates to:
  /// **'Zdrowie'**
  String get messageDomain_health;

  /// No description provided for @messageDomain_playerEvent.
  ///
  /// In pl, this message translates to:
  /// **'Zawodnicy'**
  String get messageDomain_playerEvent;

  /// No description provided for @messageDomain_teamEvent.
  ///
  /// In pl, this message translates to:
  /// **'Zespół'**
  String get messageDomain_teamEvent;

  /// No description provided for @messageDomain_roster.
  ///
  /// In pl, this message translates to:
  /// **'Skład'**
  String get messageDomain_roster;

  /// No description provided for @messageDomain_contracts.
  ///
  /// In pl, this message translates to:
  /// **'Kontrakty'**
  String get messageDomain_contracts;

  /// No description provided for @messageDomain_staff.
  ///
  /// In pl, this message translates to:
  /// **'Sztab'**
  String get messageDomain_staff;

  /// No description provided for @messageDomain_trades.
  ///
  /// In pl, this message translates to:
  /// **'Wymiany'**
  String get messageDomain_trades;

  /// No description provided for @messageDomain_draft.
  ///
  /// In pl, this message translates to:
  /// **'Draft i scouting'**
  String get messageDomain_draft;

  /// No description provided for @messageDomain_finance.
  ///
  /// In pl, this message translates to:
  /// **'Finanse'**
  String get messageDomain_finance;

  /// No description provided for @messageDomain_season.
  ///
  /// In pl, this message translates to:
  /// **'Sezon'**
  String get messageDomain_season;

  /// No description provided for @messageDomain_system.
  ///
  /// In pl, this message translates to:
  /// **'System'**
  String get messageDomain_system;

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

  /// No description provided for @trade_yourRights.
  ///
  /// In pl, this message translates to:
  /// **'Twoje prawa draftowe'**
  String get trade_yourRights;

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

  /// No description provided for @trade_theirRights.
  ///
  /// In pl, this message translates to:
  /// **'Ich prawa draftowe'**
  String get trade_theirRights;

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

  /// No description provided for @contract_pendingFinalization.
  ///
  /// In pl, this message translates to:
  /// **'Oferta przyjęta — potwierdź finalizację'**
  String get contract_pendingFinalization;

  /// No description provided for @contract_finalize.
  ///
  /// In pl, this message translates to:
  /// **'Potwierdź i podpisz'**
  String get contract_finalize;

  /// No description provided for @contract_finalizationFailed.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się sfinalizować kontraktu'**
  String get contract_finalizationFailed;

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

  /// No description provided for @contract_counterEdit.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj'**
  String get contract_counterEdit;

  /// No description provided for @contract_editCounterTitle.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj kontrofertę'**
  String get contract_editCounterTitle;

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
  /// **'Oferta zaakceptowana: {name} — potwierdź finalizację'**
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

  /// No description provided for @staff_fireDisabled.
  ///
  /// In pl, this message translates to:
  /// **'Aktywnego kontraktu nie można jeszcze zwolnić'**
  String get staff_fireDisabled;

  /// No description provided for @staff_offerPreview.
  ///
  /// In pl, this message translates to:
  /// **'Podgląd oferty'**
  String get staff_offerPreview;

  /// No description provided for @staff_profileLine.
  ///
  /// In pl, this message translates to:
  /// **'{role} · {age} lat · {nationality}'**
  String staff_profileLine(String role, int age, String nationality);

  /// No description provided for @staff_attributes.
  ///
  /// In pl, this message translates to:
  /// **'Atrybuty'**
  String get staff_attributes;

  /// No description provided for @staff_expectedSalary.
  ///
  /// In pl, this message translates to:
  /// **'Oczekiwana pensja: {salary}'**
  String staff_expectedSalary(String salary);

  /// No description provided for @staff_expectedLength.
  ///
  /// In pl, this message translates to:
  /// **'Oczekiwana długość: {years} lat'**
  String staff_expectedLength(int years);

  /// No description provided for @staff_offerScore.
  ///
  /// In pl, this message translates to:
  /// **'Wynik oferty: {score}'**
  String staff_offerScore(String score);

  /// No description provided for @staff_negotiations.
  ///
  /// In pl, this message translates to:
  /// **'Negocjacje sztabu'**
  String get staff_negotiations;

  /// No description provided for @staff_noNegotiations.
  ///
  /// In pl, this message translates to:
  /// **'Brak zapisanych negocjacji sztabu.'**
  String get staff_noNegotiations;

  /// No description provided for @staff_editCounterTitle.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj kontrofertę sztabu'**
  String get staff_editCounterTitle;

  /// No description provided for @staff_attrTactics.
  ///
  /// In pl, this message translates to:
  /// **'Taktyka'**
  String get staff_attrTactics;

  /// No description provided for @staff_attrMotivation.
  ///
  /// In pl, this message translates to:
  /// **'Motywacja'**
  String get staff_attrMotivation;

  /// No description provided for @staff_attrDevelopment.
  ///
  /// In pl, this message translates to:
  /// **'Rozwój'**
  String get staff_attrDevelopment;

  /// No description provided for @staff_attrMentoring.
  ///
  /// In pl, this message translates to:
  /// **'Mentoring'**
  String get staff_attrMentoring;

  /// No description provided for @staff_attrCoverage.
  ///
  /// In pl, this message translates to:
  /// **'Zasięg'**
  String get staff_attrCoverage;

  /// No description provided for @staff_attrEvaluation.
  ///
  /// In pl, this message translates to:
  /// **'Ocena'**
  String get staff_attrEvaluation;

  /// No description provided for @staff_attrRehabilitation.
  ///
  /// In pl, this message translates to:
  /// **'Rehabilitacja'**
  String get staff_attrRehabilitation;

  /// No description provided for @staff_attrRegeneration.
  ///
  /// In pl, this message translates to:
  /// **'Regeneracja'**
  String get staff_attrRegeneration;

  /// No description provided for @staff_attrPrevention.
  ///
  /// In pl, this message translates to:
  /// **'Prewencja'**
  String get staff_attrPrevention;

  /// No description provided for @staff_attrCare.
  ///
  /// In pl, this message translates to:
  /// **'Opieka'**
  String get staff_attrCare;

  /// No description provided for @staff_attrNegotiation.
  ///
  /// In pl, this message translates to:
  /// **'Negocjacje'**
  String get staff_attrNegotiation;

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

  /// No description provided for @matchday_weather.
  ///
  /// In pl, this message translates to:
  /// **'Pogoda'**
  String get matchday_weather;

  /// No description provided for @matchday_weather_clear.
  ///
  /// In pl, this message translates to:
  /// **'Bezchmurnie'**
  String get matchday_weather_clear;

  /// No description provided for @matchday_weather_overcast.
  ///
  /// In pl, this message translates to:
  /// **'Pochmurno'**
  String get matchday_weather_overcast;

  /// No description provided for @matchday_weather_rain.
  ///
  /// In pl, this message translates to:
  /// **'Deszcz'**
  String get matchday_weather_rain;

  /// No description provided for @matchday_weather_heavyRain.
  ///
  /// In pl, this message translates to:
  /// **'Ulewa'**
  String get matchday_weather_heavyRain;

  /// No description provided for @matchday_weather_wind.
  ///
  /// In pl, this message translates to:
  /// **'Wiatr'**
  String get matchday_weather_wind;

  /// No description provided for @matchday_weather_snow.
  ///
  /// In pl, this message translates to:
  /// **'Śnieg'**
  String get matchday_weather_snow;

  /// No description provided for @matchday_weather_heat.
  ///
  /// In pl, this message translates to:
  /// **'Upał'**
  String get matchday_weather_heat;

  /// No description provided for @matchday_weather_cold.
  ///
  /// In pl, this message translates to:
  /// **'Zimno'**
  String get matchday_weather_cold;

  /// No description provided for @matchday_temperature.
  ///
  /// In pl, this message translates to:
  /// **'{value}°C'**
  String matchday_temperature(int value);

  /// No description provided for @matchday_liveStats.
  ///
  /// In pl, this message translates to:
  /// **'Statystyki na żywo'**
  String get matchday_liveStats;

  /// No description provided for @matchday_eventFeed.
  ///
  /// In pl, this message translates to:
  /// **'Przebieg meczu'**
  String get matchday_eventFeed;

  /// No description provided for @matchday_noEvents.
  ///
  /// In pl, this message translates to:
  /// **'Brak zdarzeń'**
  String get matchday_noEvents;

  /// No description provided for @matchday_derby.
  ///
  /// In pl, this message translates to:
  /// **'Derby'**
  String get matchday_derby;

  /// No description provided for @matchday_possession.
  ///
  /// In pl, this message translates to:
  /// **'Posiadanie'**
  String get matchday_possession;

  /// No description provided for @matchday_shots.
  ///
  /// In pl, this message translates to:
  /// **'Strzały'**
  String get matchday_shots;

  /// No description provided for @matchday_xg.
  ///
  /// In pl, this message translates to:
  /// **'xG'**
  String get matchday_xg;

  /// No description provided for @matchday_onTarget.
  ///
  /// In pl, this message translates to:
  /// **'{value} cel.'**
  String matchday_onTarget(int value);

  /// No description provided for @matchday_lineup.
  ///
  /// In pl, this message translates to:
  /// **'Wyjściowa jedenastka'**
  String get matchday_lineup;

  /// No description provided for @matchday_bench.
  ///
  /// In pl, this message translates to:
  /// **'Ławka'**
  String get matchday_bench;

  /// No description provided for @matchday_noPlayers.
  ///
  /// In pl, this message translates to:
  /// **'Brak zawodników'**
  String get matchday_noPlayers;

  /// No description provided for @matchday_substitutions.
  ///
  /// In pl, this message translates to:
  /// **'Zmiany'**
  String get matchday_substitutions;

  /// No description provided for @matchday_tactics.
  ///
  /// In pl, this message translates to:
  /// **'Taktyka meczowa'**
  String get matchday_tactics;

  /// No description provided for @matchday_autoPause.
  ///
  /// In pl, this message translates to:
  /// **'Auto-pauza'**
  String get matchday_autoPause;

  /// No description provided for @matchday_autoPauseTitle.
  ///
  /// In pl, this message translates to:
  /// **'Ustawienia auto-pauzy'**
  String get matchday_autoPauseTitle;

  /// No description provided for @matchday_autoPauseInjury.
  ///
  /// In pl, this message translates to:
  /// **'Kontuzja mojego zawodnika'**
  String get matchday_autoPauseInjury;

  /// No description provided for @matchday_autoPauseRed.
  ///
  /// In pl, this message translates to:
  /// **'Czerwona kartka mojego zawodnika'**
  String get matchday_autoPauseRed;

  /// No description provided for @matchday_autoPauseHalfTime.
  ///
  /// In pl, this message translates to:
  /// **'Przerwa'**
  String get matchday_autoPauseHalfTime;

  /// No description provided for @matchday_autoPausePenalty.
  ///
  /// In pl, this message translates to:
  /// **'Rzut karny dla mojej drużyny'**
  String get matchday_autoPausePenalty;

  /// No description provided for @matchday_penaltyPauseUnavailable.
  ///
  /// In pl, this message translates to:
  /// **'W tym silniku nie ma jeszcze zdarzenia przyznania rzutu karnego.'**
  String get matchday_penaltyPauseUnavailable;

  /// No description provided for @matchday_speed.
  ///
  /// In pl, this message translates to:
  /// **'Prędkość'**
  String get matchday_speed;

  /// No description provided for @matchday_speed1.
  ///
  /// In pl, this message translates to:
  /// **'×1'**
  String get matchday_speed1;

  /// No description provided for @matchday_speed2.
  ///
  /// In pl, this message translates to:
  /// **'×2'**
  String get matchday_speed2;

  /// No description provided for @matchday_speed4.
  ///
  /// In pl, this message translates to:
  /// **'×4'**
  String get matchday_speed4;

  /// No description provided for @matchday_subsUsed.
  ///
  /// In pl, this message translates to:
  /// **'Zmiany: {used}'**
  String matchday_subsUsed(int used);

  /// No description provided for @matchday_playerMeta.
  ///
  /// In pl, this message translates to:
  /// **'{position} · OVR {ovr} · Cond {condition}'**
  String matchday_playerMeta(String position, int ovr, int condition);

  /// No description provided for @matchday_injured.
  ///
  /// In pl, this message translates to:
  /// **'Kontuzja'**
  String get matchday_injured;

  /// No description provided for @matchday_sentOff.
  ///
  /// In pl, this message translates to:
  /// **'Wyrzucony'**
  String get matchday_sentOff;

  /// No description provided for @matchday_suspended.
  ///
  /// In pl, this message translates to:
  /// **'Zawieszony'**
  String get matchday_suspended;

  /// No description provided for @matchday_yellowCard.
  ///
  /// In pl, this message translates to:
  /// **'Żółta kartka'**
  String get matchday_yellowCard;

  /// No description provided for @matchday_attention.
  ///
  /// In pl, this message translates to:
  /// **'Wymaga uwagi'**
  String get matchday_attention;

  /// No description provided for @matchday_available.
  ///
  /// In pl, this message translates to:
  /// **'Dostępny'**
  String get matchday_available;

  /// No description provided for @matchday_formationLocked.
  ///
  /// In pl, this message translates to:
  /// **'Formację można zmienić tylko w przerwie'**
  String get matchday_formationLocked;

  /// No description provided for @matchday_changesHint.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz zawodnika schodzącego i rezerwowego'**
  String get matchday_changesHint;

  /// No description provided for @matchday_tacticsHint.
  ///
  /// In pl, this message translates to:
  /// **'Zmiana taktyki poza formacją jest dostępna w trakcie gry'**
  String get matchday_tacticsHint;

  /// No description provided for @matchday_selectOutgoing.
  ///
  /// In pl, this message translates to:
  /// **'Zawodnik schodzący'**
  String get matchday_selectOutgoing;

  /// No description provided for @matchday_selectIncoming.
  ///
  /// In pl, this message translates to:
  /// **'Zawodnik wchodzący'**
  String get matchday_selectIncoming;

  /// No description provided for @matchday_confirmSubstitution.
  ///
  /// In pl, this message translates to:
  /// **'Wykonaj zmianę'**
  String get matchday_confirmSubstitution;

  /// No description provided for @matchday_substitutionSuccess.
  ///
  /// In pl, this message translates to:
  /// **'Zmiana wykonana'**
  String get matchday_substitutionSuccess;

  /// No description provided for @matchday_tacticsSuccess.
  ///
  /// In pl, this message translates to:
  /// **'Taktyka zaktualizowana'**
  String get matchday_tacticsSuccess;

  /// No description provided for @matchday_actionRejected.
  ///
  /// In pl, this message translates to:
  /// **'Nie można wykonać tej akcji'**
  String get matchday_actionRejected;

  /// No description provided for @matchday_failureMatchFinished.
  ///
  /// In pl, this message translates to:
  /// **'Mecz został zakończony'**
  String get matchday_failureMatchFinished;

  /// No description provided for @matchday_failurePlayerNotOnPitch.
  ///
  /// In pl, this message translates to:
  /// **'Zawodnik nie jest na boisku'**
  String get matchday_failurePlayerNotOnPitch;

  /// No description provided for @matchday_failurePlayerNotOnBench.
  ///
  /// In pl, this message translates to:
  /// **'Zawodnik nie jest na ławce'**
  String get matchday_failurePlayerNotOnBench;

  /// No description provided for @matchday_failurePlayerUnavailable.
  ///
  /// In pl, this message translates to:
  /// **'Zawodnik jest niedostępny'**
  String get matchday_failurePlayerUnavailable;

  /// No description provided for @matchday_failurePlayerCannotReenter.
  ///
  /// In pl, this message translates to:
  /// **'Ten zawodnik nie może wrócić na boisko'**
  String get matchday_failurePlayerCannotReenter;

  /// No description provided for @matchday_failureSubstitutionsLimit.
  ///
  /// In pl, this message translates to:
  /// **'Wykorzystano limit zmian'**
  String get matchday_failureSubstitutionsLimit;

  /// No description provided for @matchday_failureSubstitutionWindowsLimit.
  ///
  /// In pl, this message translates to:
  /// **'Wykorzystano limit okien zmian'**
  String get matchday_failureSubstitutionWindowsLimit;

  /// No description provided for @matchday_failureFormationOutsideHalfTime.
  ///
  /// In pl, this message translates to:
  /// **'Formację można zmienić tylko w przerwie'**
  String get matchday_failureFormationOutsideHalfTime;

  /// No description provided for @matchday_failureInvalidHalfTime.
  ///
  /// In pl, this message translates to:
  /// **'Akcja jest dostępna tylko w przerwie'**
  String get matchday_failureInvalidHalfTime;

  /// No description provided for @matchday_failureNoAvailableSubstitute.
  ///
  /// In pl, this message translates to:
  /// **'Brak dostępnego rezerwowego'**
  String get matchday_failureNoAvailableSubstitute;

  /// No description provided for @matchday_autoPaused.
  ///
  /// In pl, this message translates to:
  /// **'Auto-pauza: {reason}'**
  String matchday_autoPaused(String reason);

  /// No description provided for @matchday_matchProgress.
  ///
  /// In pl, this message translates to:
  /// **'Symulacja: {minute}\''**
  String matchday_matchProgress(int minute);

  /// No description provided for @matchday_summaryTitle.
  ///
  /// In pl, this message translates to:
  /// **'Podsumowanie meczu'**
  String get matchday_summaryTitle;

  /// No description provided for @matchday_summaryTeamStats.
  ///
  /// In pl, this message translates to:
  /// **'Statystyki drużyn'**
  String get matchday_summaryTeamStats;

  /// No description provided for @matchday_summaryPlayerStats.
  ///
  /// In pl, this message translates to:
  /// **'Statystyki zawodników'**
  String get matchday_summaryPlayerStats;

  /// No description provided for @matchday_summaryMOTM.
  ///
  /// In pl, this message translates to:
  /// **'Zawodnik meczu'**
  String get matchday_summaryMOTM;

  /// No description provided for @matchday_summaryInspired.
  ///
  /// In pl, this message translates to:
  /// **'Inspirujący występ'**
  String get matchday_summaryInspired;

  /// No description provided for @matchday_summaryNone.
  ///
  /// In pl, this message translates to:
  /// **'Brak'**
  String get matchday_summaryNone;

  /// No description provided for @matchday_summaryClose.
  ///
  /// In pl, this message translates to:
  /// **'Zamknij podsumowanie'**
  String get matchday_summaryClose;

  /// No description provided for @matchday_summaryNoPlayerStats.
  ///
  /// In pl, this message translates to:
  /// **'Brak statystyk zawodników'**
  String get matchday_summaryNoPlayerStats;

  /// No description provided for @matchday_summaryRating.
  ///
  /// In pl, this message translates to:
  /// **'Ocena'**
  String get matchday_summaryRating;

  /// No description provided for @matchday_summaryStamina.
  ///
  /// In pl, this message translates to:
  /// **'Kondycja'**
  String get matchday_summaryStamina;

  /// No description provided for @matchday_summaryStatus.
  ///
  /// In pl, this message translates to:
  /// **'Status'**
  String get matchday_summaryStatus;

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

  /// No description provided for @dev_progress.
  ///
  /// In pl, this message translates to:
  /// **'Postęp'**
  String get dev_progress;

  /// No description provided for @dev_growth.
  ///
  /// In pl, this message translates to:
  /// **'Tempo'**
  String get dev_growth;

  /// No description provided for @dev_weeklyOvr.
  ///
  /// In pl, this message translates to:
  /// **'OVR tyg.'**
  String get dev_weeklyOvr;

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

  /// No description provided for @rankings_rightsAsset.
  ///
  /// In pl, this message translates to:
  /// **'Prawa draftowe'**
  String get rankings_rightsAsset;

  /// No description provided for @rankings_aiValuationTeam.
  ///
  /// In pl, this message translates to:
  /// **'Wycena oczami drużyny'**
  String get rankings_aiValuationTeam;

  /// No description provided for @rankings_aiValuationDisclaimer.
  ///
  /// In pl, this message translates to:
  /// **'Wartości aktywów są liczone z perspektywy: {team}.'**
  String rankings_aiValuationDisclaimer(String team);

  /// No description provided for @rankings_openPlayer.
  ///
  /// In pl, this message translates to:
  /// **'Otwórz profil zawodnika'**
  String get rankings_openPlayer;

  /// No description provided for @rankings_aiBaseValue.
  ///
  /// In pl, this message translates to:
  /// **'Baza pointValue'**
  String get rankings_aiBaseValue;

  /// No description provided for @rankings_aiStatusAge.
  ///
  /// In pl, this message translates to:
  /// **'Mnożnik status/wiek'**
  String get rankings_aiStatusAge;

  /// No description provided for @rankings_aiNeedMultiplier.
  ///
  /// In pl, this message translates to:
  /// **'Mnożnik potrzeby'**
  String get rankings_aiNeedMultiplier;

  /// No description provided for @rankings_aiContextMultiplier.
  ///
  /// In pl, this message translates to:
  /// **'Mnożnik kontekstu'**
  String get rankings_aiContextMultiplier;

  /// No description provided for @rankings_aiProjectedSlot.
  ///
  /// In pl, this message translates to:
  /// **'Projektowany slot'**
  String get rankings_aiProjectedSlot;

  /// No description provided for @rankings_aiFutureDiscount.
  ///
  /// In pl, this message translates to:
  /// **'Dyskonto przyszłości'**
  String get rankings_aiFutureDiscount;

  /// No description provided for @rankings_aiUncertainty.
  ///
  /// In pl, this message translates to:
  /// **'Niepewność'**
  String get rankings_aiUncertainty;

  /// No description provided for @rankings_aiRightsMultiplier.
  ///
  /// In pl, this message translates to:
  /// **'Mnożnik praw'**
  String get rankings_aiRightsMultiplier;

  /// No description provided for @rankings_aiContractDrag.
  ///
  /// In pl, this message translates to:
  /// **'contractDrag'**
  String get rankings_aiContractDrag;

  /// No description provided for @rankings_aiFactors.
  ///
  /// In pl, this message translates to:
  /// **'Aktywne czynniki'**
  String get rankings_aiFactors;

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

  /// No description provided for @stats_boxScore.
  ///
  /// In pl, this message translates to:
  /// **'Pełny box score'**
  String get stats_boxScore;

  /// No description provided for @stats_shots.
  ///
  /// In pl, this message translates to:
  /// **'Strzały'**
  String get stats_shots;

  /// No description provided for @stats_shotsOnTarget.
  ///
  /// In pl, this message translates to:
  /// **'Strzały celne'**
  String get stats_shotsOnTarget;

  /// No description provided for @stats_xg.
  ///
  /// In pl, this message translates to:
  /// **'xG'**
  String get stats_xg;

  /// No description provided for @stats_passes.
  ///
  /// In pl, this message translates to:
  /// **'Podania'**
  String get stats_passes;

  /// No description provided for @stats_passAccuracy.
  ///
  /// In pl, this message translates to:
  /// **'Celność podań'**
  String get stats_passAccuracy;

  /// No description provided for @stats_duelsWon.
  ///
  /// In pl, this message translates to:
  /// **'Wygrane pojedynki'**
  String get stats_duelsWon;

  /// No description provided for @stats_offsides.
  ///
  /// In pl, this message translates to:
  /// **'Spalone'**
  String get stats_offsides;

  /// No description provided for @stats_corners.
  ///
  /// In pl, this message translates to:
  /// **'Rzuty rożne'**
  String get stats_corners;

  /// No description provided for @stats_fouls.
  ///
  /// In pl, this message translates to:
  /// **'Faule'**
  String get stats_fouls;

  /// No description provided for @stats_yellowCards.
  ///
  /// In pl, this message translates to:
  /// **'Żółte kartki'**
  String get stats_yellowCards;

  /// No description provided for @stats_redCards.
  ///
  /// In pl, this message translates to:
  /// **'Czerwone kartki'**
  String get stats_redCards;

  /// No description provided for @stats_tackles.
  ///
  /// In pl, this message translates to:
  /// **'Odbiory'**
  String get stats_tackles;

  /// No description provided for @stats_interceptions.
  ///
  /// In pl, this message translates to:
  /// **'Przechwyty'**
  String get stats_interceptions;

  /// No description provided for @stats_cleanSheets.
  ///
  /// In pl, this message translates to:
  /// **'Czyste konta'**
  String get stats_cleanSheets;

  /// No description provided for @stats_saves.
  ///
  /// In pl, this message translates to:
  /// **'Obrony'**
  String get stats_saves;

  /// No description provided for @stats_shotsFaced.
  ///
  /// In pl, this message translates to:
  /// **'Strzały przeciwko'**
  String get stats_shotsFaced;

  /// No description provided for @stats_possession.
  ///
  /// In pl, this message translates to:
  /// **'Posiadanie'**
  String get stats_possession;

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

  /// No description provided for @msg_matchPreview_title.
  ///
  /// In pl, this message translates to:
  /// **'Zapowiedź meczu'**
  String get msg_matchPreview_title;

  /// No description provided for @msg_matchPreview_body.
  ///
  /// In pl, this message translates to:
  /// **'Nadchodzący mecz drużyn ligowych.'**
  String get msg_matchPreview_body;

  /// No description provided for @msg_matchResult_title.
  ///
  /// In pl, this message translates to:
  /// **'Wynik meczu'**
  String get msg_matchResult_title;

  /// No description provided for @msg_matchResult_body.
  ///
  /// In pl, this message translates to:
  /// **'Mecz zakończył się wynikiem {homeTeam} {homeGoals}:{awayGoals} {awayTeam}.'**
  String msg_matchResult_body(
    String homeTeam,
    int homeGoals,
    int awayGoals,
    String awayTeam,
  );

  /// No description provided for @msg_walkover_title.
  ///
  /// In pl, this message translates to:
  /// **'Walkower'**
  String get msg_walkover_title;

  /// No description provided for @msg_walkover_body.
  ///
  /// In pl, this message translates to:
  /// **'Mecz zakończony walkowerem. Powód: {reason}.'**
  String msg_walkover_body(Object reason);

  /// No description provided for @msg_lineupNoGk_title.
  ///
  /// In pl, this message translates to:
  /// **'Brak bramkarza w XI'**
  String get msg_lineupNoGk_title;

  /// No description provided for @msg_lineupNoGk_body.
  ///
  /// In pl, this message translates to:
  /// **'Drużyna nie ma bramkarza w wyjściowym składzie.'**
  String get msg_lineupNoGk_body;

  /// No description provided for @msg_benchIncomplete_title.
  ///
  /// In pl, this message translates to:
  /// **'Niepełna ławka'**
  String get msg_benchIncomplete_title;

  /// No description provided for @msg_benchIncomplete_body.
  ///
  /// In pl, this message translates to:
  /// **'Na ławce brakuje {missingCount} zawodników.'**
  String msg_benchIncomplete_body(Object missingCount);

  /// No description provided for @msg_suspensionStart_title.
  ///
  /// In pl, this message translates to:
  /// **'Początek zawieszenia'**
  String get msg_suspensionStart_title;

  /// No description provided for @msg_suspensionStart_body.
  ///
  /// In pl, this message translates to:
  /// **'{playerName} pauzuje przez {games} meczów.'**
  String msg_suspensionStart_body(Object games, Object playerName);

  /// No description provided for @msg_suspensionEnd_title.
  ///
  /// In pl, this message translates to:
  /// **'Koniec zawieszenia'**
  String get msg_suspensionEnd_title;

  /// No description provided for @msg_suspensionEnd_body.
  ///
  /// In pl, this message translates to:
  /// **'{playerName} wraca do dyspozycji.'**
  String msg_suspensionEnd_body(Object playerName);

  /// No description provided for @msg_injury_title.
  ///
  /// In pl, this message translates to:
  /// **'Kontuzja'**
  String get msg_injury_title;

  /// No description provided for @msg_injury_body.
  ///
  /// In pl, this message translates to:
  /// **'{playerName}: {injuryName} ({injuryType}), absencja potrwa około {days} dni.'**
  String msg_injury_body(
    Object days,
    Object injuryName,
    Object injuryType,
    Object playerName,
  );

  /// No description provided for @msg_injuryReturn_title.
  ///
  /// In pl, this message translates to:
  /// **'Powrót po kontuzji'**
  String get msg_injuryReturn_title;

  /// No description provided for @msg_injuryReturn_body.
  ///
  /// In pl, this message translates to:
  /// **'{playerName} wraca po kontuzji {injuryName}.'**
  String msg_injuryReturn_body(Object injuryName, Object playerName);

  /// No description provided for @msg_injuryRecurrence_title.
  ///
  /// In pl, this message translates to:
  /// **'Nawrót kontuzji'**
  String get msg_injuryRecurrence_title;

  /// No description provided for @msg_injuryRecurrence_body.
  ///
  /// In pl, this message translates to:
  /// **'{playerName} ponownie odczuwa uraz {injuryName}.'**
  String msg_injuryRecurrence_body(Object injuryName, Object playerName);

  /// No description provided for @msg_potentialLoss_title.
  ///
  /// In pl, this message translates to:
  /// **'Spadek potencjału'**
  String get msg_potentialLoss_title;

  /// No description provided for @msg_potentialLoss_body.
  ///
  /// In pl, this message translates to:
  /// **'Potencjał zawodnika został obniżony.'**
  String get msg_potentialLoss_body;

  /// No description provided for @msg_playerEvent_title.
  ///
  /// In pl, this message translates to:
  /// **'Wydarzenie zawodnika'**
  String get msg_playerEvent_title;

  /// No description provided for @msg_playerEvent_body.
  ///
  /// In pl, this message translates to:
  /// **'Wymagana jest uwaga menedżera.'**
  String get msg_playerEvent_body;

  /// No description provided for @msg_teamEvent_title.
  ///
  /// In pl, this message translates to:
  /// **'Wydarzenie zespołu'**
  String get msg_teamEvent_title;

  /// No description provided for @msg_teamEvent_body.
  ///
  /// In pl, this message translates to:
  /// **'Wystąpiło wydarzenie dotyczące zespołu.'**
  String get msg_teamEvent_body;

  /// No description provided for @msg_retirementPlayer_title.
  ///
  /// In pl, this message translates to:
  /// **'Emerytura zawodnika'**
  String get msg_retirementPlayer_title;

  /// No description provided for @msg_retirementPlayer_body.
  ///
  /// In pl, this message translates to:
  /// **'{playerName} kończy karierę.'**
  String msg_retirementPlayer_body(Object playerName);

  /// No description provided for @msg_retirementStaff_title.
  ///
  /// In pl, this message translates to:
  /// **'Odejście członka sztabu'**
  String get msg_retirementStaff_title;

  /// No description provided for @msg_retirementStaff_body.
  ///
  /// In pl, this message translates to:
  /// **'Członek sztabu opuszcza klub.'**
  String get msg_retirementStaff_body;

  /// No description provided for @msg_retirementLeagueDigest_title.
  ///
  /// In pl, this message translates to:
  /// **'Emerytury w lidze'**
  String get msg_retirementLeagueDigest_title;

  /// No description provided for @msg_retirementLeagueDigest_body.
  ///
  /// In pl, this message translates to:
  /// **'Podsumowanie emerytur ligowych.'**
  String get msg_retirementLeagueDigest_body;

  /// No description provided for @msg_rosterWarning_title.
  ///
  /// In pl, this message translates to:
  /// **'Problem ze składem'**
  String get msg_rosterWarning_title;

  /// No description provided for @msg_rosterWarning_body.
  ///
  /// In pl, this message translates to:
  /// **'Skład wymaga uzupełnienia.'**
  String get msg_rosterWarning_body;

  /// No description provided for @msg_contractOffer_title.
  ///
  /// In pl, this message translates to:
  /// **'Oferta kontraktu'**
  String get msg_contractOffer_title;

  /// No description provided for @msg_contractOffer_body.
  ///
  /// In pl, this message translates to:
  /// **'Otrzymano informację dotyczącą kontraktu.'**
  String get msg_contractOffer_body;

  /// No description provided for @msg_contractSigned_title.
  ///
  /// In pl, this message translates to:
  /// **'Podpisany kontrakt'**
  String get msg_contractSigned_title;

  /// No description provided for @msg_contractSigned_body.
  ///
  /// In pl, this message translates to:
  /// **'Kontrakt został podpisany.'**
  String get msg_contractSigned_body;

  /// No description provided for @msg_contractOfferResponse_title.
  ///
  /// In pl, this message translates to:
  /// **'Odpowiedź na ofertę kontraktu'**
  String get msg_contractOfferResponse_title;

  /// No description provided for @msg_contractOfferResponse_body.
  ///
  /// In pl, this message translates to:
  /// **'Zaktualizowano negocjacje kontraktu.'**
  String get msg_contractOfferResponse_body;

  /// No description provided for @msg_contractExpiring_title.
  ///
  /// In pl, this message translates to:
  /// **'Wygasający kontrakt'**
  String get msg_contractExpiring_title;

  /// No description provided for @msg_contractExpiring_body.
  ///
  /// In pl, this message translates to:
  /// **'Kontrakt {playerName} wygasa po tym sezonie.'**
  String msg_contractExpiring_body(Object playerName);

  /// No description provided for @msg_contractLostToRival_title.
  ///
  /// In pl, this message translates to:
  /// **'Utracony cel'**
  String get msg_contractLostToRival_title;

  /// No description provided for @msg_contractLostToRival_body.
  ///
  /// In pl, this message translates to:
  /// **'{subjectName} podpisał kontrakt z {rivalTeam}.'**
  String msg_contractLostToRival_body(Object rivalTeam, Object subjectName);

  /// No description provided for @msg_contractExpired_title.
  ///
  /// In pl, this message translates to:
  /// **'Wygasły kontrakt'**
  String get msg_contractExpired_title;

  /// No description provided for @msg_contractExpired_body.
  ///
  /// In pl, this message translates to:
  /// **'Kontrakt {playerName} wygasł.'**
  String msg_contractExpired_body(Object playerName);

  /// No description provided for @msg_declineToExtend_title.
  ///
  /// In pl, this message translates to:
  /// **'Brak przedłużenia'**
  String get msg_declineToExtend_title;

  /// No description provided for @msg_declineToExtend_body.
  ///
  /// In pl, this message translates to:
  /// **'Zawodnik nie chce przedłużyć umowy.'**
  String get msg_declineToExtend_body;

  /// No description provided for @msg_rfaOfferSheet_title.
  ///
  /// In pl, this message translates to:
  /// **'Offer sheet'**
  String get msg_rfaOfferSheet_title;

  /// No description provided for @msg_rfaOfferSheet_body.
  ///
  /// In pl, this message translates to:
  /// **'Otrzymano ofertę od innego klubu.'**
  String get msg_rfaOfferSheet_body;

  /// No description provided for @msg_staffOfferResponse_title.
  ///
  /// In pl, this message translates to:
  /// **'Odpowiedź sztabu'**
  String get msg_staffOfferResponse_title;

  /// No description provided for @msg_staffOfferResponse_body.
  ///
  /// In pl, this message translates to:
  /// **'Zaktualizowano negocjacje kontraktu sztabu.'**
  String get msg_staffOfferResponse_body;

  /// No description provided for @msg_staffSigned_title.
  ///
  /// In pl, this message translates to:
  /// **'Podpisany kontrakt sztabu'**
  String get msg_staffSigned_title;

  /// No description provided for @msg_staffSigned_body.
  ///
  /// In pl, this message translates to:
  /// **'Członek sztabu podpisał nowy kontrakt.'**
  String get msg_staffSigned_body;

  /// No description provided for @msg_staffGrowth_title.
  ///
  /// In pl, this message translates to:
  /// **'Rozwój sztabu'**
  String get msg_staffGrowth_title;

  /// No description provided for @msg_staffGrowth_body.
  ///
  /// In pl, this message translates to:
  /// **'Sztab poprawił swoje umiejętności.'**
  String get msg_staffGrowth_body;

  /// No description provided for @msg_staffHired_title.
  ///
  /// In pl, this message translates to:
  /// **'Zatrudniono członka sztabu'**
  String get msg_staffHired_title;

  /// No description provided for @msg_staffHired_body.
  ///
  /// In pl, this message translates to:
  /// **'Nowy członek sztabu dołączył do klubu.'**
  String get msg_staffHired_body;

  /// No description provided for @msg_staffFired_title.
  ///
  /// In pl, this message translates to:
  /// **'Rozwiązano umowę sztabu'**
  String get msg_staffFired_title;

  /// No description provided for @msg_staffFired_body.
  ///
  /// In pl, this message translates to:
  /// **'Członek sztabu opuścił klub.'**
  String get msg_staffFired_body;

  /// No description provided for @msg_staffSlotEmpty_title.
  ///
  /// In pl, this message translates to:
  /// **'Pusty slot sztabu'**
  String get msg_staffSlotEmpty_title;

  /// No description provided for @msg_staffSlotEmpty_body.
  ///
  /// In pl, this message translates to:
  /// **'Slot sztabu wymaga obsadzenia.'**
  String get msg_staffSlotEmpty_body;

  /// No description provided for @msg_trade_title.
  ///
  /// In pl, this message translates to:
  /// **'Wymiana'**
  String get msg_trade_title;

  /// No description provided for @msg_trade_body.
  ///
  /// In pl, this message translates to:
  /// **'Aktualizacja dotycząca wymiany.'**
  String get msg_trade_body;

  /// No description provided for @msg_tradeOffer_title.
  ///
  /// In pl, this message translates to:
  /// **'Oferta wymiany'**
  String get msg_tradeOffer_title;

  /// No description provided for @msg_tradeOffer_body.
  ///
  /// In pl, this message translates to:
  /// **'Otrzymano nową ofertę wymiany.'**
  String get msg_tradeOffer_body;

  /// No description provided for @msg_tradeWindowEvent_title.
  ///
  /// In pl, this message translates to:
  /// **'Okno wymian'**
  String get msg_tradeWindowEvent_title;

  /// No description provided for @msg_tradeWindowEvent_body.
  ///
  /// In pl, this message translates to:
  /// **'Zaktualizowano informacje o oknie wymian.'**
  String get msg_tradeWindowEvent_body;

  /// No description provided for @msg_lottery_title.
  ///
  /// In pl, this message translates to:
  /// **'Loteria draftowa'**
  String get msg_lottery_title;

  /// No description provided for @msg_lottery_body.
  ///
  /// In pl, this message translates to:
  /// **'Wyniki loterii draftowej są dostępne.'**
  String get msg_lottery_body;

  /// No description provided for @msg_scoutReport_title.
  ///
  /// In pl, this message translates to:
  /// **'Raport skautingowy'**
  String get msg_scoutReport_title;

  /// No description provided for @msg_scoutReport_body.
  ///
  /// In pl, this message translates to:
  /// **'Nowe informacje skautingowe są dostępne.'**
  String get msg_scoutReport_body;

  /// No description provided for @msg_combine_title.
  ///
  /// In pl, this message translates to:
  /// **'Wyniki Combine'**
  String get msg_combine_title;

  /// No description provided for @msg_combine_body.
  ///
  /// In pl, this message translates to:
  /// **'Wyniki testów prospektów są dostępne.'**
  String get msg_combine_body;

  /// No description provided for @msg_mockDraft_title.
  ///
  /// In pl, this message translates to:
  /// **'Mock draft'**
  String get msg_mockDraft_title;

  /// No description provided for @msg_mockDraft_body.
  ///
  /// In pl, this message translates to:
  /// **'Zaktualizowano prognozę draftu.'**
  String get msg_mockDraft_body;

  /// No description provided for @msg_draftPick_title.
  ///
  /// In pl, this message translates to:
  /// **'Wybór w drafcie'**
  String get msg_draftPick_title;

  /// No description provided for @msg_draftPick_body.
  ///
  /// In pl, this message translates to:
  /// **'Nadeszła kolej wyboru w drafcie.'**
  String get msg_draftPick_body;

  /// No description provided for @msg_draftPickLeague_title.
  ///
  /// In pl, this message translates to:
  /// **'Wybór innej drużyny'**
  String get msg_draftPickLeague_title;

  /// No description provided for @msg_draftPickLeague_body.
  ///
  /// In pl, this message translates to:
  /// **'Inna drużyna dokonała wyboru w drafcie.'**
  String get msg_draftPickLeague_body;

  /// No description provided for @msg_draftedRightsReminder_title.
  ///
  /// In pl, this message translates to:
  /// **'Niepodpisany draftowany'**
  String get msg_draftedRightsReminder_title;

  /// No description provided for @msg_draftedRightsReminder_body.
  ///
  /// In pl, this message translates to:
  /// **'Masz prawa do {playerName}; roster: {rosterCount}/30.'**
  String msg_draftedRightsReminder_body(Object playerName, Object rosterCount);

  /// No description provided for @msg_apronWarning_title.
  ///
  /// In pl, this message translates to:
  /// **'Przekroczenie apronu'**
  String get msg_apronWarning_title;

  /// No description provided for @msg_apronWarning_body.
  ///
  /// In pl, this message translates to:
  /// **'Payroll przekracza dozwolony poziom.'**
  String get msg_apronWarning_body;

  /// No description provided for @msg_capUpdateTv_title.
  ///
  /// In pl, this message translates to:
  /// **'Aktualizacja salary cap'**
  String get msg_capUpdateTv_title;

  /// No description provided for @msg_capUpdateTv_body.
  ///
  /// In pl, this message translates to:
  /// **'Salary cap został zaktualizowany.'**
  String get msg_capUpdateTv_body;

  /// No description provided for @msg_staffCapViolation_title.
  ///
  /// In pl, this message translates to:
  /// **'Przekroczenie staff cap'**
  String get msg_staffCapViolation_title;

  /// No description provided for @msg_staffCapViolation_body.
  ///
  /// In pl, this message translates to:
  /// **'Payroll sztabu przekracza limit.'**
  String get msg_staffCapViolation_body;

  /// No description provided for @msg_award_title.
  ///
  /// In pl, this message translates to:
  /// **'Nagroda'**
  String get msg_award_title;

  /// No description provided for @msg_award_body.
  ///
  /// In pl, this message translates to:
  /// **'Przyznano nagrodę sezonową.'**
  String get msg_award_body;

  /// No description provided for @msg_atmosphere_title.
  ///
  /// In pl, this message translates to:
  /// **'Atmosfera zespołu'**
  String get msg_atmosphere_title;

  /// No description provided for @msg_atmosphere_body.
  ///
  /// In pl, this message translates to:
  /// **'Zmieniono poziom atmosfery w klubie.'**
  String get msg_atmosphere_body;

  /// No description provided for @msg_teamStatusChange_title.
  ///
  /// In pl, this message translates to:
  /// **'Zmiana statusu zespołu'**
  String get msg_teamStatusChange_title;

  /// No description provided for @msg_teamStatusChange_body.
  ///
  /// In pl, this message translates to:
  /// **'Status zespołu został zaktualizowany.'**
  String get msg_teamStatusChange_body;

  /// No description provided for @msg_seasonSummary_title.
  ///
  /// In pl, this message translates to:
  /// **'Podsumowanie sezonu'**
  String get msg_seasonSummary_title;

  /// No description provided for @msg_seasonSummary_body.
  ///
  /// In pl, this message translates to:
  /// **'Podsumowanie bieżącego sezonu jest gotowe.'**
  String get msg_seasonSummary_body;

  /// No description provided for @msg_playoffMissed_title.
  ///
  /// In pl, this message translates to:
  /// **'Brak awansu do playoffów'**
  String get msg_playoffMissed_title;

  /// No description provided for @msg_playoffMissed_body.
  ///
  /// In pl, this message translates to:
  /// **'Zespół nie awansował do fazy playoff.'**
  String get msg_playoffMissed_body;

  /// No description provided for @msg_calendar_title.
  ///
  /// In pl, this message translates to:
  /// **'Kalendarz'**
  String get msg_calendar_title;

  /// No description provided for @msg_calendar_body.
  ///
  /// In pl, this message translates to:
  /// **'Nowe wydarzenie w kalendarzu.'**
  String get msg_calendar_body;

  /// No description provided for @msg_system_title.
  ///
  /// In pl, this message translates to:
  /// **'Komunikat systemowy'**
  String get msg_system_title;

  /// No description provided for @msg_system_body.
  ///
  /// In pl, this message translates to:
  /// **'{message}'**
  String msg_system_body(String message);

  /// No description provided for @msg_ovrDigest_title.
  ///
  /// In pl, this message translates to:
  /// **'Rozwój OVR'**
  String get msg_ovrDigest_title;

  /// No description provided for @msg_ovrDigest_body.
  ///
  /// In pl, this message translates to:
  /// **'Podsumowanie rozwoju zawodników.'**
  String get msg_ovrDigest_body;

  /// No description provided for @msg_playerEvent_plateau_title.
  ///
  /// In pl, this message translates to:
  /// **'Plateau zawodnika'**
  String get msg_playerEvent_plateau_title;

  /// No description provided for @msg_playerEvent_plateau_body.
  ///
  /// In pl, this message translates to:
  /// **'{playerName} potrzebuje zmiany programu treningowego.'**
  String msg_playerEvent_plateau_body(Object playerName);

  /// No description provided for @msg_playerEvent_coldStreak_title.
  ///
  /// In pl, this message translates to:
  /// **'Kryzys formy'**
  String get msg_playerEvent_coldStreak_title;

  /// No description provided for @msg_playerEvent_coldStreak_body.
  ///
  /// In pl, this message translates to:
  /// **'{playerName} przechodzi kryzys formy.'**
  String msg_playerEvent_coldStreak_body(Object playerName);

  /// No description provided for @msg_playerEvent_injuryComplication_title.
  ///
  /// In pl, this message translates to:
  /// **'Komplikacje kontuzji'**
  String get msg_playerEvent_injuryComplication_title;

  /// No description provided for @msg_playerEvent_injuryComplication_body.
  ///
  /// In pl, this message translates to:
  /// **'Powrót {playerName} wymaga decyzji.'**
  String msg_playerEvent_injuryComplication_body(Object playerName);

  /// No description provided for @msg_playerEvent_veteranMotivation_title.
  ///
  /// In pl, this message translates to:
  /// **'Spadek motywacji weterana'**
  String get msg_playerEvent_veteranMotivation_title;

  /// No description provided for @msg_playerEvent_veteranMotivation_body.
  ///
  /// In pl, this message translates to:
  /// **'{playerName} potrzebuje wsparcia.'**
  String msg_playerEvent_veteranMotivation_body(Object playerName);

  /// No description provided for @msg_playerEvent_extraTraining_title.
  ///
  /// In pl, this message translates to:
  /// **'Dodatkowy trening'**
  String get msg_playerEvent_extraTraining_title;

  /// No description provided for @msg_playerEvent_extraTraining_body.
  ///
  /// In pl, this message translates to:
  /// **'{playerName} prosi o dodatkową sesję.'**
  String msg_playerEvent_extraTraining_body(Object playerName);

  /// No description provided for @msg_playerEvent_personalSupport_title.
  ///
  /// In pl, this message translates to:
  /// **'Wsparcie zawodnika'**
  String get msg_playerEvent_personalSupport_title;

  /// No description provided for @msg_playerEvent_personalSupport_body.
  ///
  /// In pl, this message translates to:
  /// **'{playerName} potrzebuje wsparcia klubu.'**
  String msg_playerEvent_personalSupport_body(Object playerName);

  /// No description provided for @msg_playerEvent_breakthrough_title.
  ///
  /// In pl, this message translates to:
  /// **'Przełom rozwojowy'**
  String get msg_playerEvent_breakthrough_title;

  /// No description provided for @msg_playerEvent_breakthrough_body.
  ///
  /// In pl, this message translates to:
  /// **'{playerName} zanotował przełom.'**
  String msg_playerEvent_breakthrough_body(Object playerName);

  /// No description provided for @msg_playerEvent_personalProblems_title.
  ///
  /// In pl, this message translates to:
  /// **'Problemy osobiste'**
  String get msg_playerEvent_personalProblems_title;

  /// No description provided for @msg_playerEvent_personalProblems_body.
  ///
  /// In pl, this message translates to:
  /// **'{playerName} ma problemy osobiste.'**
  String msg_playerEvent_personalProblems_body(Object playerName);

  /// No description provided for @msg_playerEvent_lateBloomer_title.
  ///
  /// In pl, this message translates to:
  /// **'Późny rozwój'**
  String get msg_playerEvent_lateBloomer_title;

  /// No description provided for @msg_playerEvent_lateBloomer_body.
  ///
  /// In pl, this message translates to:
  /// **'{playerName} poprawił swój atrybut.'**
  String msg_playerEvent_lateBloomer_body(Object playerName);

  /// No description provided for @msg_playerEvent_nationalTeam_title.
  ///
  /// In pl, this message translates to:
  /// **'Powołanie do kadry'**
  String get msg_playerEvent_nationalTeam_title;

  /// No description provided for @msg_playerEvent_nationalTeam_body.
  ///
  /// In pl, this message translates to:
  /// **'{playerName} otrzymał powołanie.'**
  String msg_playerEvent_nationalTeam_body(Object playerName);

  /// No description provided for @msg_playerEvent_inspiredPerformance_title.
  ///
  /// In pl, this message translates to:
  /// **'Inspirujący występ'**
  String get msg_playerEvent_inspiredPerformance_title;

  /// No description provided for @msg_playerEvent_inspiredPerformance_body.
  ///
  /// In pl, this message translates to:
  /// **'{playerName} zanotował świetny występ.'**
  String msg_playerEvent_inspiredPerformance_body(Object playerName);

  /// No description provided for @msg_teamEvent_moreMinutesRequest_title.
  ///
  /// In pl, this message translates to:
  /// **'Prośba o minuty'**
  String get msg_teamEvent_moreMinutesRequest_title;

  /// No description provided for @msg_teamEvent_moreMinutesRequest_body.
  ///
  /// In pl, this message translates to:
  /// **'{playerName} prosi o więcej minut.'**
  String msg_teamEvent_moreMinutesRequest_body(Object playerName);

  /// No description provided for @msg_teamEvent_transferRequestI_title.
  ///
  /// In pl, this message translates to:
  /// **'Prośba o transfer'**
  String get msg_teamEvent_transferRequestI_title;

  /// No description provided for @msg_teamEvent_transferRequestI_body.
  ///
  /// In pl, this message translates to:
  /// **'{playerName} chce odejść z klubu.'**
  String msg_teamEvent_transferRequestI_body(Object playerName);

  /// No description provided for @msg_teamEvent_transferRequestII_title.
  ///
  /// In pl, this message translates to:
  /// **'Żądanie transferu'**
  String get msg_teamEvent_transferRequestII_title;

  /// No description provided for @msg_teamEvent_transferRequestII_body.
  ///
  /// In pl, this message translates to:
  /// **'{playerName} ponawia żądanie transferu.'**
  String msg_teamEvent_transferRequestII_body(Object playerName);

  /// No description provided for @msg_teamEvent_dressingRoomConflict_title.
  ///
  /// In pl, this message translates to:
  /// **'Konflikt w szatni'**
  String get msg_teamEvent_dressingRoomConflict_title;

  /// No description provided for @msg_teamEvent_dressingRoomConflict_body.
  ///
  /// In pl, this message translates to:
  /// **'W szatni wybuchł konflikt.'**
  String get msg_teamEvent_dressingRoomConflict_body;

  /// No description provided for @msg_teamEvent_publicCriticism_title.
  ///
  /// In pl, this message translates to:
  /// **'Publiczna krytyka'**
  String get msg_teamEvent_publicCriticism_title;

  /// No description provided for @msg_teamEvent_publicCriticism_body.
  ///
  /// In pl, this message translates to:
  /// **'Zawodnik publicznie skrytykował menedżera.'**
  String get msg_teamEvent_publicCriticism_body;

  /// No description provided for @msg_teamEvent_declineToExtend_title.
  ///
  /// In pl, this message translates to:
  /// **'Brak przedłużenia'**
  String get msg_teamEvent_declineToExtend_title;

  /// No description provided for @msg_teamEvent_declineToExtend_body.
  ///
  /// In pl, this message translates to:
  /// **'Zawodnik nie chce przedłużyć umowy.'**
  String get msg_teamEvent_declineToExtend_body;

  /// No description provided for @msg_teamEvent_leaderSupport_title.
  ///
  /// In pl, this message translates to:
  /// **'Wsparcie lidera'**
  String get msg_teamEvent_leaderSupport_title;

  /// No description provided for @msg_teamEvent_leaderSupport_body.
  ///
  /// In pl, this message translates to:
  /// **'Lider zespołu wsparł drużynę.'**
  String get msg_teamEvent_leaderSupport_body;

  /// No description provided for @msg_teamEvent_promiseBroken_title.
  ///
  /// In pl, this message translates to:
  /// **'Złamana obietnica'**
  String get msg_teamEvent_promiseBroken_title;

  /// No description provided for @msg_teamEvent_promiseBroken_body.
  ///
  /// In pl, this message translates to:
  /// **'Nie zrealizowano obietnicy złożonej zawodnikowi.'**
  String get msg_teamEvent_promiseBroken_body;

  /// No description provided for @msg_teamEvent_atmosphereShift_title.
  ///
  /// In pl, this message translates to:
  /// **'Zmiana atmosfery'**
  String get msg_teamEvent_atmosphereShift_title;

  /// No description provided for @msg_teamEvent_atmosphereShift_body.
  ///
  /// In pl, this message translates to:
  /// **'Atmosfera zespołu uległa zmianie.'**
  String get msg_teamEvent_atmosphereShift_body;

  /// No description provided for @msg_contractOffer_accept_title.
  ///
  /// In pl, this message translates to:
  /// **'Akceptacja oferty'**
  String get msg_contractOffer_accept_title;

  /// No description provided for @msg_contractOffer_accept_body.
  ///
  /// In pl, this message translates to:
  /// **'Oferta dla {subjectName} czeka na finalizację.'**
  String msg_contractOffer_accept_body(Object subjectName);

  /// No description provided for @msg_contractOffer_reject_title.
  ///
  /// In pl, this message translates to:
  /// **'Odrzucenie oferty'**
  String get msg_contractOffer_reject_title;

  /// No description provided for @msg_contractOffer_reject_body.
  ///
  /// In pl, this message translates to:
  /// **'Oferta kontraktu została odrzucona.'**
  String get msg_contractOffer_reject_body;

  /// No description provided for @msg_contractOffer_hardReject_title.
  ///
  /// In pl, this message translates to:
  /// **'Twarde odrzucenie'**
  String get msg_contractOffer_hardReject_title;

  /// No description provided for @msg_contractOffer_hardReject_body.
  ///
  /// In pl, this message translates to:
  /// **'Negocjacje zostały zablokowane.'**
  String get msg_contractOffer_hardReject_body;

  /// No description provided for @msg_contractOffer_waiting_title.
  ///
  /// In pl, this message translates to:
  /// **'Oferta w toku'**
  String get msg_contractOffer_waiting_title;

  /// No description provided for @msg_contractOffer_waiting_body.
  ///
  /// In pl, this message translates to:
  /// **'Zawodnik rozważa ofertę.'**
  String get msg_contractOffer_waiting_body;

  /// No description provided for @msg_contractOffer_counter_title.
  ///
  /// In pl, this message translates to:
  /// **'Kontroferta'**
  String get msg_contractOffer_counter_title;

  /// No description provided for @msg_contractOffer_counter_body.
  ///
  /// In pl, this message translates to:
  /// **'Otrzymano kontrofertę kontraktu.'**
  String get msg_contractOffer_counter_body;

  /// No description provided for @msg_contractOffer_rfaQualifyingOffer_title.
  ///
  /// In pl, this message translates to:
  /// **'QO do złożenia'**
  String get msg_contractOffer_rfaQualifyingOffer_title;

  /// No description provided for @msg_contractOffer_rfaQualifyingOffer_body.
  ///
  /// In pl, this message translates to:
  /// **'Zbliża się termin złożenia Qualifying Offer.'**
  String get msg_contractOffer_rfaQualifyingOffer_body;

  /// No description provided for @msg_contractOfferResponse_accept_title.
  ///
  /// In pl, this message translates to:
  /// **'Oferta zaakceptowana'**
  String get msg_contractOfferResponse_accept_title;

  /// No description provided for @msg_contractOfferResponse_accept_body.
  ///
  /// In pl, this message translates to:
  /// **'Oferta dla {subjectName} została zaakceptowana i czeka na finalizację.'**
  String msg_contractOfferResponse_accept_body(Object subjectName);

  /// No description provided for @msg_contractOfferResponse_reject_title.
  ///
  /// In pl, this message translates to:
  /// **'Oferta odrzucona'**
  String get msg_contractOfferResponse_reject_title;

  /// No description provided for @msg_contractOfferResponse_reject_body.
  ///
  /// In pl, this message translates to:
  /// **'Oferta dla {subjectName} została odrzucona.'**
  String msg_contractOfferResponse_reject_body(Object subjectName);

  /// No description provided for @msg_contractOfferResponse_hardReject_title.
  ///
  /// In pl, this message translates to:
  /// **'Twarde odrzucenie'**
  String get msg_contractOfferResponse_hardReject_title;

  /// No description provided for @msg_contractOfferResponse_hardReject_body.
  ///
  /// In pl, this message translates to:
  /// **'Negocjacje z {subjectName} zostały zablokowane.'**
  String msg_contractOfferResponse_hardReject_body(Object subjectName);

  /// No description provided for @msg_contractOfferResponse_waiting_title.
  ///
  /// In pl, this message translates to:
  /// **'Oferta w toku'**
  String get msg_contractOfferResponse_waiting_title;

  /// No description provided for @msg_contractOfferResponse_waiting_body.
  ///
  /// In pl, this message translates to:
  /// **'{subjectName} rozważa ofertę.'**
  String msg_contractOfferResponse_waiting_body(Object subjectName);

  /// No description provided for @msg_contractOfferResponse_counter_title.
  ///
  /// In pl, this message translates to:
  /// **'Kontroferta'**
  String get msg_contractOfferResponse_counter_title;

  /// No description provided for @msg_contractOfferResponse_counter_body.
  ///
  /// In pl, this message translates to:
  /// **'{subjectName} złożył kontrofertę: {salary} na {years} lat.'**
  String msg_contractOfferResponse_counter_body(
    Object salary,
    Object subjectName,
    Object years,
  );

  /// No description provided for @msg_staffOfferResponse_accept_title.
  ///
  /// In pl, this message translates to:
  /// **'Oferta sztabu zaakceptowana'**
  String get msg_staffOfferResponse_accept_title;

  /// No description provided for @msg_staffOfferResponse_accept_body.
  ///
  /// In pl, this message translates to:
  /// **'Oferta dla {subjectName} została zaakceptowana i czeka na finalizację.'**
  String msg_staffOfferResponse_accept_body(Object subjectName);

  /// No description provided for @msg_staffOfferResponse_reject_title.
  ///
  /// In pl, this message translates to:
  /// **'Oferta sztabu odrzucona'**
  String get msg_staffOfferResponse_reject_title;

  /// No description provided for @msg_staffOfferResponse_reject_body.
  ///
  /// In pl, this message translates to:
  /// **'Oferta dla {subjectName} została odrzucona.'**
  String msg_staffOfferResponse_reject_body(Object subjectName);

  /// No description provided for @msg_staffOfferResponse_hardReject_title.
  ///
  /// In pl, this message translates to:
  /// **'Twarde odrzucenie sztabu'**
  String get msg_staffOfferResponse_hardReject_title;

  /// No description provided for @msg_staffOfferResponse_hardReject_body.
  ///
  /// In pl, this message translates to:
  /// **'Negocjacje z {subjectName} zostały zablokowane.'**
  String msg_staffOfferResponse_hardReject_body(Object subjectName);

  /// No description provided for @msg_staffOfferResponse_waiting_title.
  ///
  /// In pl, this message translates to:
  /// **'Oferta sztabu w toku'**
  String get msg_staffOfferResponse_waiting_title;

  /// No description provided for @msg_staffOfferResponse_waiting_body.
  ///
  /// In pl, this message translates to:
  /// **'{subjectName} rozważa ofertę.'**
  String msg_staffOfferResponse_waiting_body(Object subjectName);

  /// No description provided for @msg_staffOfferResponse_counter_title.
  ///
  /// In pl, this message translates to:
  /// **'Kontroferta sztabu'**
  String get msg_staffOfferResponse_counter_title;

  /// No description provided for @msg_staffOfferResponse_counter_body.
  ///
  /// In pl, this message translates to:
  /// **'{subjectName} złożył kontrofertę: {salary} na {years} lat.'**
  String msg_staffOfferResponse_counter_body(
    Object salary,
    Object subjectName,
    Object years,
  );

  /// No description provided for @msg_staffOfferResponse_lostToRival_title.
  ///
  /// In pl, this message translates to:
  /// **'Utracony cel sztabu'**
  String get msg_staffOfferResponse_lostToRival_title;

  /// No description provided for @msg_staffOfferResponse_lostToRival_body.
  ///
  /// In pl, this message translates to:
  /// **'{subjectName} podpisał kontrakt z {rivalTeam}.'**
  String msg_staffOfferResponse_lostToRival_body(
    Object rivalTeam,
    Object subjectName,
  );

  /// No description provided for @msg_contractLostToRival_lostToRival_title.
  ///
  /// In pl, this message translates to:
  /// **'Utracony cel'**
  String get msg_contractLostToRival_lostToRival_title;

  /// No description provided for @msg_contractLostToRival_lostToRival_body.
  ///
  /// In pl, this message translates to:
  /// **'{subjectName} podpisał kontrakt z {rivalTeam}.'**
  String msg_contractLostToRival_lostToRival_body(
    Object rivalTeam,
    Object subjectName,
  );

  /// No description provided for @msg_contractExpiring_player_title.
  ///
  /// In pl, this message translates to:
  /// **'Wygasający kontrakt zawodnika'**
  String get msg_contractExpiring_player_title;

  /// No description provided for @msg_contractExpiring_player_body.
  ///
  /// In pl, this message translates to:
  /// **'Kontrakt {playerName} wygasa po tym sezonie.'**
  String msg_contractExpiring_player_body(Object playerName);

  /// No description provided for @msg_contractExpiring_staff_title.
  ///
  /// In pl, this message translates to:
  /// **'Wygasający kontrakt sztabu'**
  String get msg_contractExpiring_staff_title;

  /// No description provided for @msg_contractExpiring_staff_body.
  ///
  /// In pl, this message translates to:
  /// **'Kontrakt {staffName} wygasa po tym sezonie.'**
  String msg_contractExpiring_staff_body(Object staffName);

  /// No description provided for @msg_contractExpired_player_title.
  ///
  /// In pl, this message translates to:
  /// **'Wygasły kontrakt zawodnika'**
  String get msg_contractExpired_player_title;

  /// No description provided for @msg_contractExpired_player_body.
  ///
  /// In pl, this message translates to:
  /// **'Kontrakt {playerName} wygasł.'**
  String msg_contractExpired_player_body(Object playerName);

  /// No description provided for @msg_contractExpired_staff_title.
  ///
  /// In pl, this message translates to:
  /// **'Wygasły kontrakt sztabu'**
  String get msg_contractExpired_staff_title;

  /// No description provided for @msg_contractExpired_staff_body.
  ///
  /// In pl, this message translates to:
  /// **'Kontrakt {staffName} wygasł.'**
  String msg_contractExpired_staff_body(Object staffName);

  /// No description provided for @msg_trade_counter_title.
  ///
  /// In pl, this message translates to:
  /// **'Kontroferta wymiany'**
  String get msg_trade_counter_title;

  /// No description provided for @msg_trade_counter_body.
  ///
  /// In pl, this message translates to:
  /// **'Otrzymano kontrofertę od partnera.'**
  String get msg_trade_counter_body;

  /// No description provided for @msg_trade_accepted_title.
  ///
  /// In pl, this message translates to:
  /// **'Wymiana zaakceptowana'**
  String get msg_trade_accepted_title;

  /// No description provided for @msg_trade_accepted_body.
  ///
  /// In pl, this message translates to:
  /// **'Wymiana została wykonana.'**
  String get msg_trade_accepted_body;

  /// No description provided for @msg_trade_rejected_title.
  ///
  /// In pl, this message translates to:
  /// **'Wymiana odrzucona'**
  String get msg_trade_rejected_title;

  /// No description provided for @msg_trade_rejected_body.
  ///
  /// In pl, this message translates to:
  /// **'Partner odrzucił propozycję wymiany.'**
  String get msg_trade_rejected_body;

  /// No description provided for @msg_trade_hardRejected_title.
  ///
  /// In pl, this message translates to:
  /// **'Blokada wymiany'**
  String get msg_trade_hardRejected_title;

  /// No description provided for @msg_trade_hardRejected_body.
  ///
  /// In pl, this message translates to:
  /// **'Negocjacje są zablokowane przez 30 dni.'**
  String get msg_trade_hardRejected_body;

  /// No description provided for @msg_trade_ntcRefusal_title.
  ///
  /// In pl, this message translates to:
  /// **'Odmowa NTC'**
  String get msg_trade_ntcRefusal_title;

  /// No description provided for @msg_trade_ntcRefusal_body.
  ///
  /// In pl, this message translates to:
  /// **'Zawodnik nie wyraził zgody na transfer.'**
  String get msg_trade_ntcRefusal_body;

  /// No description provided for @msg_trade_leagueDigest_title.
  ///
  /// In pl, this message translates to:
  /// **'Wymiany w lidze'**
  String get msg_trade_leagueDigest_title;

  /// No description provided for @msg_trade_leagueDigest_body.
  ///
  /// In pl, this message translates to:
  /// **'Podsumowanie wymian ligowych.'**
  String get msg_trade_leagueDigest_body;

  /// No description provided for @msg_tradeWindowEvent_open_title.
  ///
  /// In pl, this message translates to:
  /// **'Otwarcie okna wymian'**
  String get msg_tradeWindowEvent_open_title;

  /// No description provided for @msg_tradeWindowEvent_open_body.
  ///
  /// In pl, this message translates to:
  /// **'Od dziś można wykonywać wymiany.'**
  String get msg_tradeWindowEvent_open_body;

  /// No description provided for @msg_tradeWindowEvent_deadline_title.
  ///
  /// In pl, this message translates to:
  /// **'Trade deadline'**
  String get msg_tradeWindowEvent_deadline_title;

  /// No description provided for @msg_tradeWindowEvent_deadline_body.
  ///
  /// In pl, this message translates to:
  /// **'Zbliża się termin zamknięcia okna wymian.'**
  String get msg_tradeWindowEvent_deadline_body;

  /// No description provided for @msg_scoutReport_monthly_title.
  ///
  /// In pl, this message translates to:
  /// **'Miesięczny raport scouta'**
  String get msg_scoutReport_monthly_title;

  /// No description provided for @msg_scoutReport_monthly_body.
  ///
  /// In pl, this message translates to:
  /// **'Dostępny jest nowy raport scouta.'**
  String get msg_scoutReport_monthly_body;

  /// No description provided for @msg_scoutReport_event_title.
  ///
  /// In pl, this message translates to:
  /// **'Scout Report — przydziel Combine'**
  String get msg_scoutReport_event_title;

  /// No description provided for @msg_scoutReport_event_body.
  ///
  /// In pl, this message translates to:
  /// **'Przypisz prospektów do Combine.'**
  String get msg_scoutReport_event_body;

  /// No description provided for @msg_mockDraft_initial_title.
  ///
  /// In pl, this message translates to:
  /// **'Wstępny mock draft'**
  String get msg_mockDraft_initial_title;

  /// No description provided for @msg_mockDraft_initial_body.
  ///
  /// In pl, this message translates to:
  /// **'Dostępna jest wstępna prognoza draftu.'**
  String get msg_mockDraft_initial_body;

  /// No description provided for @msg_mockDraft_final_title.
  ///
  /// In pl, this message translates to:
  /// **'Finalny mock draft'**
  String get msg_mockDraft_final_title;

  /// No description provided for @msg_mockDraft_final_body.
  ///
  /// In pl, this message translates to:
  /// **'Dostępna jest finalna prognoza draftu.'**
  String get msg_mockDraft_final_body;

  /// No description provided for @msg_draftPick_own_title.
  ///
  /// In pl, this message translates to:
  /// **'Twój wybór w drafcie'**
  String get msg_draftPick_own_title;

  /// No description provided for @msg_draftPick_own_body.
  ///
  /// In pl, this message translates to:
  /// **'Nadeszła kolej Twojej drużyny.'**
  String get msg_draftPick_own_body;

  /// No description provided for @msg_draftPickLeague_league_title.
  ///
  /// In pl, this message translates to:
  /// **'Wybór ligowy'**
  String get msg_draftPickLeague_league_title;

  /// No description provided for @msg_draftPickLeague_league_body.
  ///
  /// In pl, this message translates to:
  /// **'Inna drużyna dokonała wyboru.'**
  String get msg_draftPickLeague_league_body;

  /// No description provided for @msg_playerEvent_action_accept.
  ///
  /// In pl, this message translates to:
  /// **'Akceptuj'**
  String get msg_playerEvent_action_accept;

  /// No description provided for @msg_playerEvent_action_decline.
  ///
  /// In pl, this message translates to:
  /// **'Odrzuć'**
  String get msg_playerEvent_action_decline;

  /// No description provided for @msg_playerEvent_action_cautious.
  ///
  /// In pl, this message translates to:
  /// **'Ostrożny powrót'**
  String get msg_playerEvent_action_cautious;

  /// No description provided for @msg_playerEvent_action_full.
  ///
  /// In pl, this message translates to:
  /// **'Pełne obciążenie'**
  String get msg_playerEvent_action_full;

  /// No description provided for @msg_teamEvent_action_accept.
  ///
  /// In pl, this message translates to:
  /// **'Akceptuj'**
  String get msg_teamEvent_action_accept;

  /// No description provided for @msg_teamEvent_action_decline.
  ///
  /// In pl, this message translates to:
  /// **'Odrzuć'**
  String get msg_teamEvent_action_decline;

  /// No description provided for @msg_teamEvent_action_intervene.
  ///
  /// In pl, this message translates to:
  /// **'Interweniuj'**
  String get msg_teamEvent_action_intervene;

  /// No description provided for @msg_teamEvent_action_ignore.
  ///
  /// In pl, this message translates to:
  /// **'Zignoruj'**
  String get msg_teamEvent_action_ignore;

  /// No description provided for @msg_teamEvent_action_response.
  ///
  /// In pl, this message translates to:
  /// **'Odpowiedz publicznie'**
  String get msg_teamEvent_action_response;

  /// No description provided for @msg_teamEvent_action_punish.
  ///
  /// In pl, this message translates to:
  /// **'Kara dyscyplinarna'**
  String get msg_teamEvent_action_punish;

  /// No description provided for @msg_contractOffer_action_finalize.
  ///
  /// In pl, this message translates to:
  /// **'Finalizuj'**
  String get msg_contractOffer_action_finalize;

  /// No description provided for @msg_contractOffer_action_cancel.
  ///
  /// In pl, this message translates to:
  /// **'Anuluj'**
  String get msg_contractOffer_action_cancel;

  /// No description provided for @msg_contractOffer_action_accept.
  ///
  /// In pl, this message translates to:
  /// **'Akceptuj'**
  String get msg_contractOffer_action_accept;

  /// No description provided for @msg_contractOffer_action_counter.
  ///
  /// In pl, this message translates to:
  /// **'Złóż kontrofertę'**
  String get msg_contractOffer_action_counter;

  /// No description provided for @msg_contractOffer_action_decline.
  ///
  /// In pl, this message translates to:
  /// **'Odrzuć'**
  String get msg_contractOffer_action_decline;

  /// No description provided for @msg_contractOffer_action_submit.
  ///
  /// In pl, this message translates to:
  /// **'Złóż QO'**
  String get msg_contractOffer_action_submit;

  /// No description provided for @msg_contractOfferResponse_action_accept.
  ///
  /// In pl, this message translates to:
  /// **'Akceptuj'**
  String get msg_contractOfferResponse_action_accept;

  /// No description provided for @msg_contractOfferResponse_action_counter.
  ///
  /// In pl, this message translates to:
  /// **'Złóż kontrofertę'**
  String get msg_contractOfferResponse_action_counter;

  /// No description provided for @msg_contractOfferResponse_action_decline.
  ///
  /// In pl, this message translates to:
  /// **'Odrzuć'**
  String get msg_contractOfferResponse_action_decline;

  /// No description provided for @msg_staffOfferResponse_action_accept.
  ///
  /// In pl, this message translates to:
  /// **'Akceptuj'**
  String get msg_staffOfferResponse_action_accept;

  /// No description provided for @msg_staffOfferResponse_action_counter.
  ///
  /// In pl, this message translates to:
  /// **'Złóż kontrofertę'**
  String get msg_staffOfferResponse_action_counter;

  /// No description provided for @msg_staffOfferResponse_action_decline.
  ///
  /// In pl, this message translates to:
  /// **'Odrzuć'**
  String get msg_staffOfferResponse_action_decline;

  /// No description provided for @msg_tradeOffer_action_accept.
  ///
  /// In pl, this message translates to:
  /// **'Akceptuj'**
  String get msg_tradeOffer_action_accept;

  /// No description provided for @msg_tradeOffer_action_counter.
  ///
  /// In pl, this message translates to:
  /// **'Kontroferta'**
  String get msg_tradeOffer_action_counter;

  /// No description provided for @msg_tradeOffer_action_reject.
  ///
  /// In pl, this message translates to:
  /// **'Odrzuć'**
  String get msg_tradeOffer_action_reject;

  /// No description provided for @msg_trade_action_accept.
  ///
  /// In pl, this message translates to:
  /// **'Akceptuj'**
  String get msg_trade_action_accept;

  /// No description provided for @msg_trade_action_counter.
  ///
  /// In pl, this message translates to:
  /// **'Kontroferta'**
  String get msg_trade_action_counter;

  /// No description provided for @msg_trade_action_reject.
  ///
  /// In pl, this message translates to:
  /// **'Odrzuć'**
  String get msg_trade_action_reject;

  /// No description provided for @msg_scoutReport_action_openWatchlist.
  ///
  /// In pl, this message translates to:
  /// **'Otwórz watchlistę'**
  String get msg_scoutReport_action_openWatchlist;

  /// No description provided for @msg_draftPick_action_openDraft.
  ///
  /// In pl, this message translates to:
  /// **'Otwórz draft'**
  String get msg_draftPick_action_openDraft;

  /// No description provided for @msg_retirementLeagueDigest_digest_title.
  ///
  /// In pl, this message translates to:
  /// **'Emerytury ligowe'**
  String get msg_retirementLeagueDigest_digest_title;

  /// No description provided for @msg_retirementLeagueDigest_digest_body.
  ///
  /// In pl, this message translates to:
  /// **'{count} zawodników zakończyło karierę w tygodniu {week}.'**
  String msg_retirementLeagueDigest_digest_body(int count, int week);

  /// No description provided for @msg_draftPickLeague_digest_title.
  ///
  /// In pl, this message translates to:
  /// **'Wybory w rundzie draftu'**
  String get msg_draftPickLeague_digest_title;

  /// No description provided for @msg_draftPickLeague_digest_body.
  ///
  /// In pl, this message translates to:
  /// **'Podsumowanie wyborów innych drużyn.'**
  String get msg_draftPickLeague_digest_body;

  /// No description provided for @msg_staffGrowth_digest_title.
  ///
  /// In pl, this message translates to:
  /// **'Rozwój sztabu'**
  String get msg_staffGrowth_digest_title;

  /// No description provided for @msg_staffGrowth_digest_body.
  ///
  /// In pl, this message translates to:
  /// **'Podsumowanie zmian w sztabie.'**
  String get msg_staffGrowth_digest_body;

  /// No description provided for @msg_trade_digest_title.
  ///
  /// In pl, this message translates to:
  /// **'Wymiany w lidze'**
  String get msg_trade_digest_title;

  /// No description provided for @msg_trade_digest_body.
  ///
  /// In pl, this message translates to:
  /// **'Podsumowanie wymian w tygodniu {week}.'**
  String msg_trade_digest_body(int week);

  /// No description provided for @msg_ovrDigest_digest_title.
  ///
  /// In pl, this message translates to:
  /// **'Rozwój OVR'**
  String get msg_ovrDigest_digest_title;

  /// No description provided for @msg_ovrDigest_digest_body.
  ///
  /// In pl, this message translates to:
  /// **'{count} zawodników poprawiło OVR w tygodniu {week}.'**
  String msg_ovrDigest_digest_body(int count, int week);

  /// No description provided for @msg_calendar_newWeek_title.
  ///
  /// In pl, this message translates to:
  /// **'Nowy tydzień'**
  String get msg_calendar_newWeek_title;

  /// No description provided for @msg_calendar_newWeek_body.
  ///
  /// In pl, this message translates to:
  /// **'Rozpoczął się tydzień {week}.'**
  String msg_calendar_newWeek_body(Object week);

  /// No description provided for @msg_contractSigned_fa_title.
  ///
  /// In pl, this message translates to:
  /// **'Kontrakt podpisany'**
  String get msg_contractSigned_fa_title;

  /// No description provided for @msg_contractSigned_fa_body.
  ///
  /// In pl, this message translates to:
  /// **'Zawodnik podpisał kontrakt z klubem.'**
  String get msg_contractSigned_fa_body;
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
