# New Football: przegląd UI/UX (statyczny)

**Autor:** Uxie (UI/UX) · **Data:** 2026-11-13 · **Commit:** `f103dd9` (main)
**Zakres:** warstwa `lib/app` (29 307 linii: ekrany, widgety, motyw, nawigacja).
**Skala priorytetów:** krytyczny / ważny / kosmetyczny. Krytycznych znalezisk w UI brak.
**Ograniczenie:** przegląd zrobiony na podstawie kodu, bez uruchamiania aplikacji i bez zrzutów ekranu. Punkty dotyczące układu (overflow, kontrast na konkretnych tłach) warto potwierdzić na urządzeniu.

Odwołania `ścieżka:linia` są względem katalogu głównego repozytorium i pochodzą z weryfikacji tego commita.

## Podsumowanie

Fundament jest dobry: Material 3, ciemny motyw z kolorami klubu, generowanie kontrastowego koloru tekstu (`foregroundFor`), lokalizacja EN/PL przez ARB, tooltipy w głównym pasku aplikacji, licznik nieprzeczytanych wiadomości. Największe problemy to niespójna lokalizacja (część ekranów ma tekst po polsku na sztywno), przeładowana dolna nawigacja i dostępność (brak tooltipów, zbyt małe czcionki, statusy kodowane czerwienią i zielenią — drugi nośnik informacji jest tylko w części tych miejsc).

| # | Problem | Priorytet |
|---|---|---|
| 1 | Teksty na sztywno w draftcie i loterii omijają l10n | Ważny |
| 2 | 6 zakładek w dolnej nawigacji | Ważny |
| 3 | 28 przycisków-ikon bez tooltipu, głównie własne „wstecz” | Ważny |
| 4 | Statusy czerwony/zielony — drugi nośnik niepełny | Ważny |
| 5 | Czcionki 8–10 pt | Ważny |
| 6 | Kolory statusów na sztywno zamiast z motywu | Kosmetyczny |
| 7 | Surowy wyjątek pokazywany graczowi | Kosmetyczny |
| 8 | Ekran „Inne” jako płaska lista 14 pozycji | Kosmetyczny |

## 1. Teksty na sztywno omijają lokalizację (ważny)

Aplikacja ma `lib/l10n/app_en.arb` i `lib/l10n/app_pl.arb`, ale część ekranów ma polski (albo angielski) tekst wpisany w kod. Gracz z angielskim językiem zobaczy w nich polski, a w jednym miejscu jest mieszanka (zakładka „Draft Order” obok „Prospekty”).

- `lib/app/screens/draft_screen.dart`:
  - `109` — „Brak aktywnej ligi” (ten sam literał jest też w loterii, `lib/app/screens/lottery_screen.dart:44`)
  - `123` — „Draft niedostępny”
  - `187` — „Draft Order”
  - `191` — „Prospekty”
  - `372` — „Rozpocznij draft”
  - `382` i `401` — „Symuluj wybór”
  - `389` i `408` — „Symuluj do mojego wyboru”
  - `419` — „Zakończ”
  - `487` — „Opuść draft”
  - `495` — „Nie”, `499` — „Tak”
  - `699` — „Wybierz gracza”
  - `636` — „Dane skautingowe”
  - `458` — „Wybrano: …”
  - `300` — „Runda …”
  - W tym samym pliku są też: `103`, `117`, `134` — tytuł „Draft”; `172` — „Twoja kolej! Wybierz prospekta z zakładki Prospekty.”; `236` — „Draft zakończony!”; `336` — „Brak dostępnych prospektów”; `489`–`490` — treść dialogu wyjścia; `626` — „… lat”; `641` — „Brak danych skautingowych. …”; `648` — „Combine Score”; `652` — „Scout Grade”; `656` — „Potencjał”; `664` — „Podatność na kontuzje”; `673` — „Determinacja”; `682` — „Estymowany slot” (tak zapisane w kodzie); `31` — skrót wieku „y”; `36` — „Combine …”.
- `lib/app/screens/lottery_screen.dart`:
  - `38` i `55` — „Loteria draftowa”
  - `44` — „Brak aktywnej ligi”
  - `132` — „Rozpocznij losowanie”
  - `162` — „Pokaż kolejny pick”
  - `175` — „Przejdź do wyników”
  - `205` — „Zakończ losowanie”
  - `326` — „Opuść losowanie”
  - `328`–`329` — treść dialogu wyjścia
  - `334` — „Nie”, `338` — „Tak”
  - `307` — „Błąd zapisu: …” (osobno w punkcie 7)
- `lib/app/widgets/lottery_odds_table.dart`: `14` — „#”, `15` — „Drużyna”, `16` — „Szanse (%)”.
- `lib/app/widgets/lottery_results_table.dart`: `33` — „Pick”, `34` — „Drużyna”.
- `lib/app/screens/draft_history_screen.dart:95` — „Original rank: …” (po angielsku na sztywno; reszta tego ekranu idzie przez `l10n`).
- `lib/app/utils/squad_roster_presentation.dart`: `120` — „XI”, `126` — „Bench”, `132` — „Reserves”.
- `lib/app/widgets/staff_rating_stars.dart`: `22` — domyślna wartość parametru `unavailableLabel` („Staff rating unavailable”); `240` — ta sama etykieta wpisana drugi raz w `Semantics.label` i nieużywająca parametru. Obok, `21` — domyślne „Staff slot empty”.

**Poprawka:** przenieść wszystkie powyższe do ARB (EN + PL). Warto dodać do CI prosty lint, który blokuje `Text('...')` z literałem w `lib/app` (wyjątki: liczby, symbole).

## 2. Przeładowana dolna nawigacja (ważny)

`lib/app/screens/shell_screen.dart` ma 6 zakładek. Widgety: `76`–`83` (`HomeScreen`, `CalendarScreen`, `SquadScreen`, `StandingsScreen`, `OtherScreen`, `InboxScreen`). Etykiety w `NavigationDestination`: `183`–`187` Start (`shell_tab_home`), `188`–`192` Kalendarz, `193`–`197` Skład, `198`–`202` Tabela, `203`–`207` Inne, `208`–`220` Skrzynka. Polskie napisy: `lib/l10n/app_pl.arb:297`, `291`, `292`, `294`, `298`, `296`. Wytyczne Material zalecają 3–5. Na wąskich telefonach etykiety (już ustawione na 11 pt w `lib/app/theme/app_theme.dart:119`–`121`) będą się ścieśniać albo ucinać.

**Poprawka (do wyboru):**
- przenieść Skrzynkę do ikony z licznikiem w AppBar (obok zapisu), albo
- przenieść Tabelę do „Inne”/Startu, jeśli gracz zagląda tam rzadziej niż do kalendarza i składu.

## 3. Przyciski „wstecz” bez tooltipu (ważny)

Na wielu ekranach jest własny `IconButton(icon: Icon(Icons.arrow_back), onPressed: () => context.pop())` bez `tooltip`. Czytnik ekranu ogłosi tylko „przycisk”, a na iOS ikona nie pasuje do platformy. Liczba 28 zgadza się z kodem: tyle jest wywołań `IconButton(` w `lib/app`, w których w tym wywołaniu nie ma `tooltip`. `IconButton.filledTonal` w `lib/app/screens/search_screen.dart:94` tooltip ma (`95`) i do tej liczby nie wchodzi.

Własne „wstecz” bez tooltipu (20):

- `lib/app/screens/draft_screen.dart:104`, `:118`, `:135`
- `lib/app/screens/lottery_screen.dart:39`, `:56`
- `lib/app/screens/contract_screen.dart:105`
- `lib/app/screens/free_agency_screen.dart:168`
- `lib/app/screens/staff_screen.dart:89`
- `lib/app/screens/player_detail_screen.dart:85`
- `lib/app/screens/settings_screen.dart:87`
- `lib/app/screens/load_game_screen.dart:42`
- `lib/app/screens/new_game_screen.dart:70`
- `lib/app/screens/player_stats_screen.dart:56`
- `lib/app/screens/prospects_screen.dart:275`
- `lib/app/screens/rankings_screen.dart:55`
- `lib/app/screens/rewards_screen.dart:58`
- `lib/app/screens/search_screen.dart:122`
- `lib/app/screens/search_filters_screen.dart:86`
- `lib/app/screens/draft_history_screen.dart:112`
- `lib/app/screens/trade_screen.dart:164`

Poza „wstecz” (8):

- `lib/app/screens/search_screen.dart:82` — `Icons.clear`
- `lib/app/screens/search_filter_controls.dart:113` — `Icons.remove`; `:133` — `Icons.add`
- `lib/app/screens/calendar_screen_body.dart:231` — `Icons.chevron_left`; `:257` — `Icons.chevron_right` (ikona w `:272`)
- `lib/app/widgets/tactics/role_picker_sheet.dart:49` — `Icons.info_outline`
- `lib/app/screens/free_agency_player_sections.dart:18` — `Icons.clear`; `:144` — `Icons.info_outline`

Osiem innych `IconButton` ze strzałką wstecz tooltip już ma i w te 28 nie wchodzi. Tekst tooltipu to `l10n.common_cancel`, nie „wstecz”: `lib/app/screens/team_overview_screen.dart:83` i `:448`, `lib/app/screens/trade_history_screen.dart:88`, `lib/app/screens/development_screen.dart:79` i `:103`, `lib/app/screens/finance_screen.dart:107` i `:130`, `lib/app/router.dart:77`.

**Poprawka:** zastąpić własne „wstecz” standardowym `BackButton()` (albo po prostu pozwolić AppBar wstawić go automatycznie). Ma zlokalizowany tooltip i ikonę zależną od platformy. Pozostałym `IconButton` dodać `tooltip` z ARB. To też usuwa sporo powtarzanego kodu.

## 4. Informacja przekazywana tylko kolorem (ważny)

Po zestawieniu z kodem sformułowanie „tylko kolorem” jest za mocne: w czterech z pięciu wymienionych miejsc jest już drugi nośnik. Zostaje kodowanie czerwienią i zielenią (albo zielenią i pomarańczem) oraz ramka wyniku bez litery W/R/P. Ok. 8% mężczyzn ma deuteranopię lub protanopię i nie odróżni tych barw, gdy kształt albo tekst nie wystarczy.

- Wynik meczu, `lib/app/widgets/calendar_day_result_popup.dart:144`–`146`: ramka karty (`48`, `51`) jest zielona przy wygranej, czerwona przy przegranej i żółta przy remisie. Sam wynik jest liczbą (`178`) i ma etykietę `Semantics` oraz tooltip (`157`–`169`). Brakuje litery albo ikony W/R/P przy ramce; remis nie jest trzecim stanem czerwony/zielony.
- Zmiany ocen w rozwoju, `lib/app/screens/development_screen.dart:464`–`465`: dodatnia zmiana jest zielona, ujemna czerwona. Tekst ma już znak: `470` (`+$delta`) oraz `490`–`495`. Drugi nośnik tu jest.
- Trend prospektów, `lib/app/screens/prospects_screen.dart:90`–`107`: wzrost to zielona strzałka w górę, spadek czerwona w dół (`101`–`102`), zero to niebieska pauza (`95`–`96`). Ikona jest drugim nośnikiem; zostaje para zielony/czerwony plus niebieski.
- Dostępność gracza, `lib/app/screens/player_detail_screen.dart:195`–`202`: ikona `check_circle` albo `healing`, kolor zielony albo pomarańczowy (nie czerwony) i zlokalizowany tytuł. Sam kolor nie jest jedynym kanałem.
- Skala indykatorów składu, `lib/app/widgets/squad/squad_indicators.dart:122`–`123` (czerwony/zielony) i ikona `check` albo `close` w `134`–`137`. Kolor toru bierze się też z `lib/app/utils/squad_roster_presentation.dart:78`. Ikona jest widoczna, ale `semanticLabel` jest `null` (`140`), więc czytnik ekranu tej pary nie ogłosi.

**Poprawka:** tam, gdzie drugiego nośnika nie ma (ramka wyniku), dodać znak (+/−), strzałkę, ikonę albo literę (W/R/P). Przy składzie uzupełnić `semanticLabel`. Rozważyć paletę bezpieczną dla daltonistów (np. niebieski/pomarańczowy) jako opcję w ustawieniach — także w miejscach, które ikonę już mają, bo sam kolor ikony nadal jest czerwony albo zielony.

## 5. Zbyt małe czcionki (ważny)

Wartości `fontSize` 8, 9 i 10 w `lib/app`:

- `lib/app/widgets/tactics/player_tile_metrics.dart:153` — 8
- `lib/app/screens/matchday_lineup_widgets.dart:142` — 9; `:175` — 9; `:170` — 10
- `lib/app/screens/prospects_screen.dart:96` i `:107` — 9
- `lib/app/widgets/tactics/pitch_field.dart:275` i `:336` — 10
- `lib/app/screens/player_detail_screen.dart:473` — 10

Tekst poniżej ok. 11–12 pt jest trudny do przeczytania na telefonie, szczególnie na ciemnym tle w trakcie meczu. W tych samych plikach są też literały 11 i 12 (`pitch_field.dart:262` i `:292`, `matchday_lineup_widgets.dart:152`); problemem pozostają 8–10.

Plus: `lib/app/screens/squad_screen.dart:317` i `lib/app/widgets/tactics/player_tile_badges.dart:37` już uwzględniają `textScaler`, ale reszta ekranów z wąskimi kafelkami nie, więc przy powiększonej czcionce systemowej możliwe są overflow.

**Poprawka:** minimum 11 pt, korzystać z `theme.textTheme.labelSmall` itp. zamiast literałów. Przetestować ekrany meczu, składu i boiska przy skali tekstu 1.3–1.5.

## 6. Kolory statusów na sztywno (kosmetyczny)

W `lib/app` jest 133 wystąpienia `Colors.` albo `Color(0x…)` (128 linii; pięć linii ma po dwa tokeny). Najwięcej nie w boisku i kopercie: `lib/app/utils/color_interpolation.dart` — 37, `lib/app/branding/club_color_tokens.dart` — 19, a dopiero potem po 12 w `lib/app/widgets/tactics/pitch_field.dart` i `lib/app/widgets/envelope_animation.dart`. Wstępne „ok. 128, najwięcej w pitch i envelope” tego podziału nie oddaje. Duża część tokenów w `color_interpolation.dart` i `club_color_tokens.dart` to skale i kolory klubu, nie statusy ekranów.

Statusy (wygrana/przegrana, ostrzeżenia, priorytety zdarzeń w meczu, progi salary cap) są i tak kodowane ręcznie (`Colors.red` / `green` / `orange` / `amber` / `blue`) zamiast z motywu. Przy motywie klubowym kolor statusu może zlewać się z kolorem klubu (np. czerwony status na czerwonym AppBarze klubu).

Przykłady:

- wygrana/przegrana/remis: `lib/app/widgets/calendar_day_result_popup.dart:144`–`146`
- zmiana oceny: `lib/app/screens/development_screen.dart:464`–`465`
- trend prospektu: `lib/app/screens/prospects_screen.dart:95`–`96`, `:101`
- dostępność: `lib/app/screens/player_detail_screen.dart:197`
- skala składu: `lib/app/widgets/squad/squad_indicators.dart:122`–`123`, `lib/app/utils/squad_roster_presentation.dart:78`, `:121`, `:127`, `:133`
- kontuzja albo złe stanowisko: `lib/app/utils/squad_status_presentation.dart:118`–`119`; na boisku `lib/app/widgets/tactics/pitch_field.dart:255`–`257`
- priorytet zdarzenia meczowego: `lib/app/screens/matchday_screen.dart:691`–`693` (próg błędu bierze `scheme.error`, progi pomarańczowy i bursztynowy są na sztywno)
- progi salary cap: `lib/app/screens/finance_screen.dart:228`–`231`
- wspólne skale czerwony/pomarańczowy/niebieski: `lib/app/utils/color_interpolation.dart:39`–`40`, `:44`, `:49`–`50`, `:54`, `:60`–`61`, `:65`, `:78`–`79`, `:92`–`93`

**Poprawka:** dodać `ThemeExtension` z kolorami semantycznymi (`success`, `warning`, `danger`, `info`, `neutral`) i z niego korzystać w ekranach. Ułatwi to też punkt 4.

## 7. Surowy wyjątek pokazywany graczowi (kosmetyczny)

`lib/app/screens/lottery_screen.dart:307`: `SnackBar(content: Text('Błąd zapisu: $e'))` pokaże graczowi techniczną treść wyjątku.

**Poprawka:** zlokalizowany, zrozumiały komunikat („Nie udało się zapisać gry. Spróbuj ponownie.”) z akcją „Ponów”, a szczegóły do logów.

## 8. Ekran „Inne” (kosmetyczny)

`lib/app/screens/other_screen.dart` to płaska lista 14 pozycji (`13`–`44`), nie ok. 15. Ikona `groups_outlined` jest użyta dwa razy: przegląd drużyn (`15`) i sztab (`28`).

1. `14` — historia wymian (`swap_horiz`)
2. `15` — przegląd drużyn (`groups_outlined`)
3. `16`–`20` — finanse
4. `21` — kontrakty
5. `22`–`26` — wolni agenci
6. `27` — prospekty
7. `28` — sztab (`groups_outlined`, ta sama ikona co w `15`)
8. `29` — rozwój
9. `30` — statystyki
10. `31` — nagrody
11. `32` — szukaj
12. `33`–`37` — historia draftu
13. `38` — rankingi
14. `39`–`43` — lista obserwowanych

**Poprawka:** pogrupować w sekcje z nagłówkami (Drużyna: skład, sztab, rozwój, finanse, kontrakty; Rynek: wolni agenci, wymiany, prospekty, szukaj; Liga: statystyki, rankingi, nagrody, historia draftu). Nadać sztabowi własną ikonę (np. `badge_outlined` albo `sports`). Lista obserwowanych może zostać przy prospektach.

## Co działa dobrze

- Motyw klubowy z automatycznym kontrastem tekstu na kolorach klubu: `foregroundFor` w `lib/app/branding/club_color_tokens.dart:249`, użycie w `lib/app/theme/app_theme.dart:26`–`27`. Material 3: `lib/app/theme/app_theme.dart:73` (`useMaterial3: true`).
- Tooltipy w AppBarze shella: `lib/app/screens/shell_screen.dart:152`–`165` (ustawienia, zapis, wyjście). Licznik nieprzeczytanych w nawigacji: `209`–`218`, widget `287`–`305` (`Badge` przy `unreadCount > 0`).
- `PopScope` w draftcie (`lib/app/screens/draft_screen.dart:127`) i loterii (`lib/app/screens/lottery_screen.dart:48`) chroni przed przypadkowym wyjściem.
- Blokada interakcji (`AbsorbPointer`) podczas wychodzenia z gry: `lib/app/screens/shell_screen.dart:170`–`172`.
- Symulacja dnia w osobnym izolacie, więc UI nie zamarza: `lib/main.dart:22`–`26` (`IsolateSimulationRunner`), implementacja `lib/core/services/simulation_worker.dart:138`.

## Proponowana kolejność

1. Punkt 1 (lokalizacja), bo to widoczny błąd dla każdego gracza EN.
2. Punkty 3 i 5 (szybkie, mechaniczne poprawki dostępności).
3. Punkty 4 i 6 razem (semantyczne kolory w motywie).
4. Punkty 2 i 8 (decyzja projektowa Adama co do nawigacji).
5. Punkt 7.
