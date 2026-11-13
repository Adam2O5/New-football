# Analiza testów New Football — 2026-11-13

Raport końcowy dla zespołu. Kod aplikacji i testów nie był zmieniany. Priorytet: **krytyczny** (psuje mistrza, ziarno play-off, nagrodę albo chowa taką regresję przed CI), **ważny** (psuje wynik w realnym przypadku brzegowym albo zostawia tę ścieżkę bez asercji), **kosmetyczny** (nazwa, liczba, układ pliku; po naprawie zachowanie gry się nie zmienia).

Przebieg z 2026-11-13: Flutter 3.41.4 / Dart 3.11.1, `flutter test --concurrency 4 --reporter compact`. Wynik: **1851 passed, 1 skipped, 0 failed**, 2:29, kod 0. Jedyny `skip:` w aktywnych `*_test.dart` to nagrody w `test/calendar/task39_season_service_test.dart:297`. Poza przebiegiem: 17 plików `*_long.dart` i 42 pliki `*.dart.disabled`.

| Priorytet | Liczba |
| --- | ---: |
| krytyczny | 5 |
| ważny | 10 |
| kosmetyczny | 6 |

## Krytyczny

### K1. Identyfikator serii play-off jest UUID i wchodzi do seeda dogrywki oraz karnych

- **Priorytet:** krytyczny
- **Gdzie:** `lib/core/services/season_service.dart:190` (`id: _uuid.v4()`), `lib/core/services/season_post_match.dart:196` (`matchSeed(saveSeed, seasonYear, '$matchId:tiebreak')`), `lib/core/random/seeds.dart:30`
- **Opis:** Mecz pucharowy ma id `playoff:${series.id}:${n}`. Przy remisie `_resolvePostseasonTiebreak` losuje dogrywkę (próg `nextDouble() < 0.55`, linie 205–222) albo karne (linie 225–240) z `Random(matchSeed(...))`. Skoro `series.id` jest nowe przy każdym `setupPlayoffs`, ten sam `saveSeed` daje inny `matchId`, inny seed i inny zwycięzcę. Zapis po wygenerowaniu drabinki jest stabilny. Wejście w play-off drugi raz z tego samego stanu już nie. `test/data/initial_roster_replay_test.dart:29` świadomie pomija UUID przy porównaniu nowej kariery, więc tej dziury nie widzi.
- **Poprawka:** id serii z roku, konferencji, rundy i obu drużyn. UUID zostaje przy meta zapisu (`lib/core/services/game_factory.dart:116`) i przy wiadomościach.

```dart
PlayoffSeries _series(String high, String low, {required String id}) =>
    PlayoffSeries(
      id: id, // np. '2026:europe:qf:0:$high:$low'
      higherSeedTeamId: high,
      lowerSeedTeamId: low,
      winsNeeded: 3,
    );
```

Przypadki testowe są w sekcji „Trzy luki”.

### K2. Pełna drabinka i remisy pucharowe są tylko w archiwum

- **Priorytet:** krytyczny
- **Gdzie:** `test/blacklist.json:407` (wpis), `deferredCases` w liniach 413–416; ciała w `test/calendar/disabled/task39_season_service_test_deferred.dart.disabled:295` i `:368`. Aktywny substytut `test/calendar/calendar_service_test.dart:162` sprawdza tylko, że po środzie są dwa `playInProgress`, a po sobocie dwa wyniki z niepustym `homeTeamId`.
- **Opis:** Powód na liście brzmi „listed AI/engine cases are deferred”. Test remisów (`:372`) podstawia `_TiedAiMatchdayService`, który zwraca 0:0 i nie woła silnika. Przywrócenie całego pliku disabled wciągnęłoby też stare fixture nagród. Wystarczą dwa przypadki, pod aktualnym `SeasonService(aiMatchdayService:)`. Dziś CI nie sprawdza: jednego mistrza, BO5 zakończonego po trzech wygranych, tego że każdy remis ma `wentToExtraTime` i `winnerTeamId`, ani że część remisów schodzi do karnych.
- **Poprawka:** nowy plik `test/calendar/playoff_bracket_test.dart` (szkice niżej). Z blacklisty usunąć tylko te dwa `deferredCases`, reszty archiwum nie włączać. Po K1 oba przebiegi z tym samym seedem mają dać te same id serii i tego samego mistrza.

### K3. „Gole obronione” bramkarza to strzały minus jego gole, a test nagród jest na stałe pominięty

- **Priorytet:** krytyczny
- **Gdzie:** `lib/core/services/season_awards.dart:586` (`goalsPrevented = (stats.shotsFaced - stats.goals).clamp(...)`), waga `gkGoalsPreventedWeight = 0.20` w `lib/core/balance/draft_awards_balance.dart:76`, użycie w `_bestGoalkeeper` `season_awards.dart:371`. Test: `test/calendar/task39_season_service_test.dart:297` (`skip:`). Komentarz protezy: `season_awards.dart:565`.
- **Opis:** Do oceny najlepszego bramkarza wchodzi liczba, która maleje, gdy bramkarz sam strzeli gola, i nie zna goli straconych. Dwóch bramkarzy z tym samym `shotsFaced`, tymi samymi obronami, czystymi kontami i oceną: ten, który strzelił, przegrywa ranking. Test „computes award leaders from player stats and is idempotent” pinował `bestGkPlayerId` i jest pominięty, więc CI jest zielone (jedno skipped w przebiegu). `test/balance/gameplay_rules_test.dart:50` sprawdza tylko próg minut na kadrze dwuosobowej. Komunikat `skip` odsyła do notatki przy `_AwardStats`, ale zostawia martwe fixture w zestawie.
- **Poprawka:** kolumna `goalsConceded` w `PlayerSeasonStats`, liczona w `_recordSeasonStats`, oraz:

```dart
goalsPrevented = (stats.shotsFaced - stats.goalsConceded).clamp(0, stats.shotsFaced);
```

Do czasu kolumny składnik `gkGoalsPreventedWeight` ma być 0, a test niżej ma przechodzić (własny gol bramkarza nie zmienia werdyktu). `skip:` usunąć. Martwego pinowania starych zwycięzców nie przywracać, dopóki akumulator punktów drużyny i minut na slocie nie wróci. Zostawić osobny, krótki test idempotencji: drugie `runAwards` nie dopisuje wiadomości.

### K4. Tie-break tabeli, loterii i draftu urywa się na punktach i różnicy bramek

- **Priorytet:** krytyczny
- **Gdzie:** `lib/core/models/standing.dart:67`, `lib/core/services/draft_service.dart:84`, `lib/core/services/season_lottery.dart:34`. Pełny klucz jest już przy trenerze roku: `lib/core/services/season_awards.dart:472` (punkty, różnica, bramki, `teamId`).
- **Opis:** Play-off bierze nasiona z `ConferenceStandings.sorted` (`lib/core/services/season_playoffs.dart:6`). Loteria sortuje najgorszych na początek tym samym niepełnym kluczem i podaje listę do `LotteryService.computeResults`. Draft układa drużyny spoza loterii tak samo (`draft_service.dart:84`), potem odwraca. Przy równych punktach i równej różnicy `List.sort` nie gwarantuje stabilności, więc miejsce 8/9 (play-in) i granica „kto ma kulę w loterii” mogą się zamienić między przebiegami. `test/market/draft_order_test.dart:57` nazywa przypadek „tied standings”, ale w fixture (`:37`) `goalsFor: i` przy `goalsAgainst == 0` rozstrzyga różnicę bramek. Remisu punktowo-bramkowego nie ma w żadnym teście.
- **Poprawka:** jeden komparator. Tabela (lepszy wyżej): punkty, różnica, bramki zdobyte, `teamId`. Loteria i draft: ten sam klucz, odwrotny kierunek trzech pierwszych pól, `teamId` rosnąco jako ostatni, żeby remis całkowity nie zależał od strony sortowania.

```dart
int compareStandingsBestFirst(Standing a, Standing b) {
  final points = b.points.compareTo(a.points);
  if (points != 0) return points;
  final difference = b.goalDifference.compareTo(a.goalDifference);
  if (difference != 0) return difference;
  final goals = b.goalsFor.compareTo(a.goalsFor);
  if (goals != 0) return goals;
  return a.teamId.compareTo(b.teamId);
}
```

### K5. Złote testy silnika meczu wołają usunięte `MatchEngine`

- **Priorytet:** krytyczny
- **Gdzie:** `test/match/disabled/match_engine_test.dart.disabled:15` (`const engine = MatchEngine()`), zakaz powrotu klasy w `test/core/source_boundaries_test.dart:14`. Aktywne pokrycie: `test/match/active_match_runtime_test.dart`, `test/balance/active_simulation_balance_test.dart`. `test/ai` nie ma aktywnego `*_test.dart`.
- **Opis:** W `test/match/disabled` leżą strzały, incydenty, momentum, pętla minutowa i wynik (taski 15–23). Odkomentowanie nie skompiluje się z obecnym `SimulationMatchEngine`. Aktywne testy pilnują bootstrapu i mnożników balansu, nie tego, że ten sam seed daje ten sam wynik, ani że faul zapisuje się jako kartka. Taski AI 32–37 (draft, transfer, kadra, matchday) są w całości na blackliście.
- **Poprawka:** nie włączać plików z `MatchEngine`. Dodać krótki `test/match/simulation_match_engine_contract_test.dart`:

```dart
test('simulateFullMatch is deterministic for one seed', () {
  const engine = SimulationMatchEngine();
  final first = engine.simulateFullMatch(
    home: home,
    away: away,
    context: const MatchContext(),
    saveSeed: 1234,
    seasonYear: 2026,
    week: 1,
    matchId: 'match-17',
  );
  final second = engine.simulateFullMatch(
    home: home,
    away: away,
    context: const MatchContext(),
    saveSeed: 1234,
    seasonYear: 2026,
    week: 1,
    matchId: 'match-17',
  );
  expect(second.homeGoals, first.homeGoals);
  expect(second.awayGoals, first.awayGoals);
  expect(second.playerStats.map((s) => s.playerId), first.playerStats.map((s) => s.playerId));
});
```

Sygnaturę `simulateFullMatch` dopasować do `lib/core/simulation/match_engine.dart:2069` w momencie pisania testu. AI zostawić na blackliście do czasu przeniesienia pojedynczych `deferredCases`.

## Ważny

### W1. Remis bez zwycięzcy dopisuje wygraną niżej rozstawionemu

- **Priorytet:** ważny
- **Gdzie:** `lib/core/models/match_models.dart:257`
- **Opis:** Gdy `winnerTeamId` jest puste, wyżej rozstawiony dostaje wygraną tylko przy większej liczbie goli. Remis wpada w `else` i podbija `lowerSeedWins` (`:266`). Produkcja woła wcześniej `_resolvePostseasonTiebreak`, więc ścieżka jest uśpiona. Karne zostawiają remis w golach i ustawiają `winnerTeamId` — to jest poprawne.
- **Poprawka:**

```dart
if (resolvedWinner == null && result.homeGoals == result.awayGoals) {
  throw StateError('Series ${id} recorded a draw without a winner');
}
```

Test `recordGame rejects a draw that has no winner` oraz `recordGame gives the shootout winner the game` (gole 0:0, `wentToShootout: true`, `winnerTeamId` niżej rozstawionego, `lowerSeedWins == 1`).

### W2. Zapasowy tie-break play-in ignoruje saveSeed

- **Priorytet:** ważny
- **Gdzie:** `lib/core/services/season_service.dart:182`
- **Opis:** Przy równych golach, bez `winnerTeamId` i bez karnych, `_winnerId` liczy `matchSeed(0, 0, 'legacy-tiebreak:$homeId:$awayId')`. Wołane z `lib/core/services/season_play_in.dart:175` i `:248`. Po poprawnym tie-breaku gałąź jest martwa. Wynik 0:0, który ją ominie, ma tego samego zwycięzcę przy każdym ziamie zapisu.
- **Poprawka:** nie rozstrzygać remisu tutaj. Niech wołający zawsze przejdzie przez `_resolvePostseasonTiebreak`. Test: dwa `saveSeed`, ten sam remis po tie-breaku, różni zwycięzcy tylko gdy seed wchodzi do `matchSeed`.

### W3. Średnia ocen sezonu miesza minuty z liczbą występów

- **Priorytet:** ważny
- **Gdzie:** `lib/core/services/match_post_match_service.dart:179`. Ten sam wzorzec wag w `lib/core/models/player.dart:99`.
- **Opis:** Przy `minutes == 0` waga starej oceny to `appearances`, a waga bieżącego wpisu to `1`. Występ dolicza się tylko przy `minutes > 0` (`:192`). Kartka przy zerze minut nie jest występem, ale przy kolejnym takim wpisie poprzednia ocena ma wagę 0 i znika. Żaden test nie czyta `seasonStats` po `applyMatchPlayerEffects`.
- **Poprawka:** waga wyłącznie w minutach; przy 0 minut nie zmieniać `ratingAvg`.

```dart
test('two matches average rating by minutes and sum goals', () {
  var player = seedPlayer;
  player = apply(player, minutes: 90, rating: 8, goals: 1, passes: 20, passAccuracy: 0.8);
  player = apply(player, minutes: 45, rating: 6, goals: 1, passes: 10, passAccuracy: 1.0);
  final row = player.seasonStats.single;
  expect(row.goals, 2);
  expect(row.ratingAvg, closeTo((8 * 90 + 6 * 45) / 135, 1e-9));
  expect(row.passAccuracy, closeTo((0.8 * 20 + 1.0 * 10) / 30, 1e-9));
  expect(row.appearances, 2);
});
```

### W4. Próg capu „zapisany czy domyślny” poznaje się po różnicy wobec globalnego defaultu

- **Priorytet:** ważny
- **Gdzie:** `lib/core/services/salary_cap_service.dart:141`
- **Opis:** `_thresholds` traktuje finanse jak niezapisane, gdy cap i oba fartuchy są równe `BalanceConfig.defaults`. Wtedy wstrzyknięty `balance` nadpisuje kwotę zapisaną na drużynie. Po aktualizacji TV (`:416`) wszystkie trzy progi się zmieniają i heurystyka trafia. Brak testu: finanse równe defaultowi, serwis z innym capem.
- **Poprawka:** jawna flaga `thresholdsSynced` na `TeamFinance`. Test: drużyna z capem równym defaultowi i `SalaryCapService(balance: BalanceConfig(salaryCap: SalaryCapBalance(salaryCap: 200000000)))` zwraca cap z drużyny, gdy flaga jest ustawiona, a cap z balansu, gdy nie jest.

### W5. Agregacja statystyk sezonowych i ekran statystyk nie mają testu

- **Priorytet:** ważny
- **Gdzie:** zapis `lib/core/services/match_post_match_service.dart:167`, suma kariery `lib/core/models/player.dart:49`. Brak odwołań do `PlayerStatsScreen` i `aggregatePlayerSeasonStats` w `test/`.
- **Opis:** Gole, asysty, xG, czyste konta, obrony i MOTM składają się na wiersz, z którego liczone są nagrody (K3). Samobóje są na `PlayerMatchStats` i w ocenie meczowej (`lib/core/simulation/match_stats.dart`), a w `PlayerSeasonStats` kolumny nie ma. Błąd sumy nie wywali żadnego testu.
- **Poprawka:** test z W3 plus `aggregatePlayerSeasonStats` na dwóch latach (gole się sumują, ocena waży minuty, nie średnią arytmetyczną lat). Osobno decyzja: kolumna `ownGoals` albo test, który dokumentuje, że sezon samobójów nie trzyma.

### W6. Terminarz sprawdza liczności, nie pary i boiska

- **Priorytet:** ważny
- **Gdzie:** `test/data/schedule_generator_test.dart:4`. Generator: `lib/core/services/schedule_generator.dart:13`.
- **Opis:** Asercje to 870 meczów, 58 kolejek, 58 meczów na drużynę. Tyle samo da układ, w którym drużyna gra sama ze sobą albo dwa razy u siebie z tym samym rywalem. Dni tygodnia (`:19`) są dobrze przypięte do seedów. Nieparzysta liczba drużyn (`ArgumentError`, generator `:14`) nie jest testowana.
- **Poprawka:**

```dart
test('each pair meets twice, once at each ground, never against itself', () {
  final schedule = const ScheduleGenerator().generateDoubleRoundRobin(ids);
  final homes = <String, Set<String>>{};
  for (final match in schedule) {
    expect(match.homeTeamId, isNot(match.awayTeamId));
    expect(homes.putIfAbsent(match.homeTeamId, () => {}).add(match.awayTeamId), isTrue);
  }
  for (final id in ids) {
    expect(homes[id], hasLength(29));
  }
  expect(
    () => const ScheduleGenerator().generateDoubleRoundRobin(['a', 'b', 'c']),
    throwsArgumentError,
  );
});
```

### W7. Loteria przy mniej niż 10 drużynach i polityka draftu AI

- **Priorytet:** ważny
- **Gdzie:** `lib/core/services/lottery_service.dart:39` (zwrot `const []`), archiwum `test/ai/disabled/task36_ai_draft_test.dart.disabled`. Aktywne i dobre: `test/market/draft_order_test.dart`, `test/calendar/season_randomness_test.dart:119`.
- **Opis:** Przy krótszej liście niż tabela wag (10 pozycji, `draft_awards_balance.dart:52`) loteria zwraca pustą listę. `runLottery` bierze potem `.first` (to osobno, C6). Wybór prospekta przez AI, bonus bramkarza po picku 45 i limit combine są tylko w archiwum. Remis na granicy loterii jest w K4.
- **Poprawka:** test `computeResults returns an empty list when fewer than 10 teams are supplied` oraz, osobnym PR-em, jeden `deferredCases` z tasku 36, nie cały plik.

### W8. Granica payrollu równego capowi nie jest przypięta

- **Priorytet:** ważny
- **Gdzie:** `lib/core/services/salary_cap_service.dart:165`. Reguły wymiany są pokryte w `test/market/salary_cap_rules_test.dart:61`. Drugie `runCapUpdateTv` (`:384`) sprawdza liczbę wiadomości, nie kwotę.
- **Opis:** Status to `overCap` dopiero przy `payroll > cap`, a fartuch przy `>=`. Payroll równy capowi jest `underCap`. Tego progu nie ma w teście. Powtórna aktualizacja TV mogłaby podnieść cap drugi raz, a test by przeszedł, byle deduplikacja wiadomości zadziałała.
- **Poprawka:**

```dart
test('payroll equal to the cap stays under the cap', () {
  final onCap = _teamWithPayroll(sourceTeam, sourceTeam.finance.salaryCap);
  expect(const SalaryCapService().snapshot(onCap).status, CapStatus.underCap);
  final over = _teamWithPayroll(sourceTeam, sourceTeam.finance.salaryCap + 1);
  expect(const SalaryCapService().snapshot(over).status, CapStatus.overCap);
});
```

Oraz `expect(repeated.teams.first.finance.salaryCap, updated.teams.first.finance.salaryCap)`.

### W9. Ekran tabeli sprawdza przebudowy, nie kolejność

- **Priorytet:** ważny
- **Gdzie:** `test/ui/career_screen_rebuilds_test.dart:61`. Brak testu `PlayoffBracketView` (`lib/app/widgets/standings/standings_bracket_view.dart`).
- **Opis:** Test liczy, ile razy `StandingsScreen` się przebudował. Nie czyta miejsca w konferencji ani wyniku serii. Po K4 zła kolejność wierszy nie wyjdzie na CI.
- **Poprawka:** widget z trzema wierszami (więcej punktów; remis punktów i lepsza różnica; remis punktów i różnicy, wyższe `teamId`) i asercja kolejności tekstu nazw. Osobno jedna seria 2:1 na `PlayoffBracketView`.

### W10. Wykluczenie `*_long.dart` i blacklisty jest szczelne, ale chowa też przypadki funkcjonalne

- **Priorytet:** ważny
- **Gdzie:** `scripts/test_support.ps1:54` (profil `long` bierze tylko `*_long.dart`, inaczej tylko `*_test.dart`), `scripts/test_support.ps1:47` (zakaz `*_test.dart` w `long/` i `disabled/`), `scripts/test.ps1:24` (profil `long` rzuca, gdy ustawione jest CI), `.github/workflows/ci.yml:38` (`-Profile standard`). Blacklista: `test/blacklist.json`, walidacja `scripts/test_support.ps1:32` (plik musi kończyć się `.dart.disabled`).
- **Opis:** `flutter test` i `dart test` same z siebie ładują wyłącznie `*_test.dart`. Plik `*_long.dart` jest niewidoczny, dopóki ktoś nie poda ścieżki albo nie uruchomi profilu `long`. W CI ten profil jest zablokowany. Plik `.disabled` nie jest kompilowany; brak wpisu w manifeście wywala selektor, import `.disabled` z aktywnego testu też. To dobre zabezpieczenie przed przypadkowym włączeniem 15-minutowego benchmarku i przed starym `MatchEngine`. Skutek uboczny: `test/calendar/long/season_progression_long.dart:55` (dojście do play-in), `test/performance/long/simulation_worker_long.dart:32` (ta sama data po izolacie) i `test/performance/long/save_size_guard_long.dart:118` (budżet rozmiaru zapisu) nie chodzą na PR. K2 jest wykluczone drugi raz, przez blacklistę, choć nie jest testem wydajnościowym.
- **Poprawka:** benchmarki (`*measurements*`, `save_repository_baseline_long.dart`) zostają poza CI. Z `season_progression_long`, `simulation_worker_long` i `save_size_guard_long` wyciąć asercje funkcjonalne do `*_test.dart`. Przypadki K2 przenieść do aktywnego pliku, nie do profilu `long`. Profil `long` dalej ręczny. Szczegóły w sekcji o stylu.

## Kosmetyczny

### C1. Plik „property” bez tagu i z dwoma ręcznymi przypadkami

- **Priorytet:** kosmetyczny
- **Gdzie:** `test/calendar/urgent_message_simulation_true_policy_property_test.dart:1` (sam `library;`). Sąsiad ma tag: `test/calendar/urgent_message_simulation_false_policy_property_test.dart:1`, a `:25` ustawia `_property4CaseCount = 2`.
- **Opis:** `flutter test -t property` pomija plik true. CI i tak uruchamia wszystko poza `*_long` i `.disabled`, więc to nie jest dziura w GitHub Actions. Nazwa „property” przy dwóch ręcznych planach myli się z `glados`.
- **Poprawka:** `@Tags(['property'])` na obu plikach albo, lepiej, jeden plik opisany w sekcji stylu. Jeśli zostają dwa plany, zdjąć „property” z nazwy.

### C2. Kwoty capu wpisane liczbowo obok obiektu, który je niesie

- **Priorytet:** kosmetyczny
- **Gdzie:** `test/market/salary_cap_rules_test.dart:27` i `:370` (`385000000`, `436370000`, `474870000`).
- **Opis:** Test +10% jest wartościowy, ale recenzent nie widzi, że 385 mln to `350 * 1.10`. Te same progi są powtórzone w `expect` na `TeamFinance()` (`:38`).
- **Poprawka:**

```dart
expect(finance.salaryCap, balance.salaryCap.salaryCap);
final updatedCap = (source.finance.salaryCap * 110) ~/ 100;
expect(updatedTeam.finance.salaryCap, updatedCap);
expect(
  updatedTeam.finance.firstApron,
  (source.finance.firstApron * updatedCap / source.finance.salaryCap).round(),
);
```

### C3. Nazwa „tied standings” przy bilansie, który nie jest remisem

- **Priorytet:** kosmetyczny
- **Gdzie:** `test/market/draft_order_test.dart:37` i `:57`
- **Opis:** Dla `i >= 10` wygrane są równe 20, ale `goalsFor` rośnie, więc różnica bramek rozstrzyga kolejność. Test dobrze pilnuje 90 slotów i picków wymienionych. Nazwa sugeruje pokrycie K4.
- **Poprawka:** nazwa `lottery order, then non-lottery teams by goal difference`. Remis dodać osobnym testem z sekcji K4, tego przypadku nie przerabiać.

### C4. Numery tasków i mieszany język nazw

- **Priorytet:** kosmetyczny
- **Gdzie:** `test/calendar/task39_season_service_test.dart:261`, `test/market/salary_cap_rules_test.dart:26` („Task 27”), `test/balance/i05_contracts_completion_test.dart`, polski tytuł w `test/ui/finance_dashboard_test.dart:15`.
- **Opis:** `--plain-name` i czerwony log CI mieszają polski, angielski i numer zadania, którego nie ma w teście.
- **Poprawka:** przy edycji nazywać zachowanie po angielsku (`tv cap increases once by the stored percent`). Hurtowo nie przepisywać.

### C5. Ekran finansów asercją „czy jest nagłówek”

- **Priorytet:** kosmetyczny
- **Gdzie:** `test/ui/finance_dashboard_test.dart:25`
- **Opis:** `find.text('Aprony')` przejdzie przy złej kwocie fartucha. Payroll jest sprawdzany przez `formatMoney` (`:27`). Drugi test (stan powyżej capu, `:37`) jest konkretniejszy.
- **Poprawka:** `expect(find.text(formatMoney(context, snapshot.firstApron)), findsOneWidget)` i to samo dla `secondApron` oraz `snapshot.cap`.

### C6. `runLottery` rzuca, gdy lista loterii jest pusta

- **Priorytet:** kosmetyczny
- **Gdzie:** `lib/core/services/season_lottery.dart:15` (`.first` na picku nr 1). Pusty zwrot: `lib/core/services/lottery_service.dart:39`.
- **Opis:** Liga ma 30 drużyn, więc `.first` nie pada w normalnej karierze. Pada na fixture krótszym niż 10 drużyn i na teście, który wszedłby w `runLottery` zamiast w `buildDraftOrder`. `draft_order_test.dart:155` pustą loterię podaje wprost do `buildDraftOrder` i oczekuje powtórzonych slotów — to omija `.first`.
- **Poprawka:**

```dart
if (lottery.isEmpty) {
  throw StateError('Lottery produced no pick 1 for ${league.teams.length} teams');
}
```

Komunikat z liczbą drużyn zamiast `Bad state: No element`. Test z W7 ma oczekiwać tego wyjątku albo pustego, obsłużonego stanu, zależnie od wybranej umowy.

## Trzy luki — proponowane testy

Poniższe szkice są do wklejenia po poprawkach K1, K3 i K4. Dziś pierwszy i trzeci mają paść. Drugi pada na obecnej formule i przechodzi po odcięciu własnych goli bramkarza od rankingu.

### a) Determinizm play-off i drabinka z archiwum

Plik: `test/calendar/playoff_bracket_test.dart`. Helper `finalRegularSeasonDay()` jest już w `test/helpers/fixtures/game_fixtures.dart` (używa go `postseason_finalization_test.dart`). Sztuczny mecz 0:0 wziąć z `_TiedAiMatchdayService` w archiwum (`task39_season_service_test_deferred.dart.disabled:252`); sygnatura `simulateFullMatch` zgadza się z `AiMatchdayService` (`lib/core/ai/ai_matchday_service.dart:188`).

Nazwa: `setupPlayoffs repeats series ids for the same standings`.

```dart
test('setupPlayoffs repeats series ids for the same standings', () {
  final state = finalRegularSeasonDay();
  List<String> ids(LeagueState league) => [
    for (final bracket in league.currentSeason.playoffBrackets)
      for (final series in bracket.quarterFinals) series.id,
  ];
  final first = SeasonService().setupPlayoffs(state);
  final second = SeasonService().setupPlayoffs(state);
  expect(ids(second), ids(first));
  expect(ids(first).toSet(), hasLength(ids(first).length));
});
```

Dziś `Uuid.v4()` w `season_service.dart:191` daje inne id. Po K1 test przechodzi i łapie regresję seeda, zanim ktokolwiek zagra mecz.

Nazwa: `tied play-in and playoffs repeat extra time, penalties and the champion`.

```dart
test('tied play-in and playoffs repeat extra time, penalties and the champion', () {
  const seed = 3903;
  LeagueState play(int saveSeed) {
    final service = SeasonService(aiMatchdayService: _TiedMatchday());
    var state = _newLeague(seed: seed).copyWith(currentWeek: 31, currentDay: 3);
    state = service.advancePlayInForDate(state, week: 31, day: 3, saveSeed: saveSeed).league;
    state = service
        .advancePlayInForDate(
          state.copyWith(currentWeek: 31, currentDay: 6),
          week: 31,
          day: 6,
          saveSeed: saveSeed,
        )
        .league;
    final games = [
      for (final result in state.currentSeason.playInResults) ...[
        result.game7v8,
        result.game9v10,
        result.gameFinal,
      ],
    ];
    expect(games, hasLength(6));
    expect(games, everyElement(predicate<MatchResult>(
      (game) => game.wentToExtraTime && game.winnerTeamId != null,
    )));
    expect(games.any((game) => game.wentToShootout), isTrue);
    state = service.setupPlayoffs(state);
    for (var week = 32; week <= 43 && state.currentSeason.championTeamId == null; week++) {
      for (final day in [3, 6]) {
        if (state.currentSeason.championTeamId != null) break;
        state = service
            .advancePlayoffsForDate(
              state.copyWith(currentWeek: week, currentDay: day),
              week: week,
              day: day,
              saveSeed: saveSeed,
            )
            .league;
      }
    }
    return state;
  }

  final first = play(seed);
  final second = play(seed);
  expect(second.currentSeason.championTeamId, first.currentSeason.championTeamId);
  expect(second.currentSeason.championTeamId, isNotNull);
  expect(
    [
      for (final bracket in second.currentSeason.playoffBrackets)
        bracket.leagueFinal?.id,
    ],
    [
      for (final bracket in first.currentSeason.playoffBrackets)
        bracket.leagueFinal?.id,
    ],
  );
}, timeout: const Timeout(Duration(minutes: 2)));
```

To jest treść dwóch testów z archiwum (`:295` i `:368`) plus porównanie dwóch przebiegów. Sam fakt „jest mistrz” nie łapie UUID: mistrz może paść tak samo, a karne już nie. Dlatego asercja jest na `championTeamId` i na id finału. Timeout 2 minuty jest w archiwum (`:365`); przenieść go razem z testem. Nie wrzucać tego do `*_long.dart`.

Nazwa: `a best-of-five series stops after three wins`.

```dart
test('a best-of-five series stops after three wins', () {
  final service = SeasonService(aiMatchdayService: _HomeWinsMatchday());
  var state = service.setupPlayoffs(finalRegularSeasonDay());
  for (var week = 32; week <= 34; week++) {
    for (final day in [3, 6]) {
      state = service
          .advancePlayoffsForDate(
            state.copyWith(currentWeek: week, currentDay: day),
            week: week,
            day: day,
            saveSeed: 3901,
          )
          .league;
    }
  }
  final series = state.currentSeason.playoffBrackets.first.quarterFinals.first;
  expect(series.isComplete, isTrue);
  expect(series.games, hasLength(3));
  expect(
    state.currentSeason.postseasonFixtures.where(
      (match) => match.id.startsWith('playoff:${series.id}:') && match.result == null,
    ),
    isEmpty,
  );
});
```

`_HomeWinsMatchday` zwraca 1:0 dla gospodarza. Dziś id serii i tak jest losowe, więc prefiks `playoff:${series.id}:` jest spójny w jednym przebiegu. Test pilnuje reguły z `season_playoffs.dart:184`: seria skończona w trzy mecze nie gra zaległych.

### b) Gole obronione i pominięty test nagród

Próg minut najlepszego bramkarza to `possibleMinutes * bestGkMinutesPct` (`season_awards.dart:99`, udział 0.40 w `draft_awards_balance.dart:91`). W `gameplay_rules_test.dart:61` próg jest spełniony przez `minutes: 2088`. Tę samą liczbę dać obu bramkarzom, inaczej test spadnie na progu, nie na formule.

Nazwa: `a goalkeeper own goal tally does not decide the award`.

```dart
test('a goalkeeper own goal tally does not decide the award', () {
  final league = controllerSave().leagueState;
  final team = league.playerTeam!;
  final keepers = team.roster.where((p) => p.position == Position.gk).take(2).toList();
  Player row(Player player, {required int goals}) => player.copyWith(
    seasonStats: [
      PlayerSeasonStats(
        year: league.currentSeason.year,
        minutes: 2088,
        appearances: 24,
        shotsFaced: 80,
        saves: 60,
        cleanSheets: 10,
        goals: goals,
        ratingAvg: 7,
      ),
    ],
  );
  final quiet = row(keepers[0], goals: 0);
  final scorer = row(keepers[1], goals: 3);
  final awarded = SeasonService()
      .runAwards(league.updateTeam(team.copyWith(roster: [quiet, scorer])))
      .currentSeason
      .awards!;
  // Remis składników bramkarskich rozstrzyga player.id, nie gole strzelone.
  final expected = [quiet.id, scorer.id]..sort();
  expect(awarded.bestGkPlayerId, expected.first);
});
```

Dziś `goalsPrevented` cichego bramkarza to 80, strzelca 77 (`season_awards.dart:586`), więc wygrywa cichy, o ile jego id nie jest i tak pierwsze. Żeby test był ostry także gdy id cichego jest mniejsze, asercja powyżej jest właściwa dopiero po wyjęciu `stats.goals` z formuły. Wariant, który pada na obecnym kodzie niezależnie od id:

```dart
test('the keeper who conceded fewer shots on target ranks first at equal saves', () {
  // Po dodaniu goalsConceded. Dziś pole nie istnieje — test jest czerwony celowo.
  final stingy = row(keepers[0], goalsConceded: 10);
  final leaky = row(keepers[1], goalsConceded: 25);
  expect(awarded.bestGkPlayerId, stingy.id);
});
```

Nazwa: `runAwards is idempotent without pinning the old leaderboard`.

Zastępuje pominięty test z `task39_season_service_test.dart:261`. Nie porównywać `mvpPlayerId` ze starym fixture.

```dart
test('runAwards is idempotent without pinning the old leaderboard', () {
  final league = controllerSave().leagueState;
  final service = SeasonService();
  final first = service.runAwards(league);
  final again = service.runAwards(first);
  expect(again.currentSeason.awards, first.currentSeason.awards);
  expect(again.inbox.messages, first.inbox.messages);
  expect(
    first.inbox.messages.where((message) => message.type == MessageType.seasonSummary),
    hasLength(1),
  );
});
```

`skip:` z linii 297 usunąć razem ze starym ciałem. Zostawienie `skip` i dopisanie nowego testu obok zostawia w CI „1 skipped” bez informacji, który kontrakt jest martwy.

### c) Tie-break tabeli, loterii i draftu

Nazwa: `equal points and goal difference rank by goals scored, then team id`.

```dart
test('equal points and goal difference rank by goals scored, then team id', () {
  final table = ConferenceStandings(
    conference: Conference.europe,
    standings: const [
      Standing(teamId: 'b', wins: 10, goalsFor: 30, goalsAgainst: 20),
      Standing(teamId: 'a', wins: 10, goalsFor: 20, goalsAgainst: 10),
      Standing(teamId: 'c', wins: 11, goalsFor: 1, goalsAgainst: 0),
    ],
  );
  final ranked = table.sorted;
  expect(ranked.map((s) => s.teamId), ['c', 'b', 'a']);
  expect(ranked.map((s) => s.conferenceRank), [1, 2, 3]);

  final level = ConferenceStandings(
    conference: Conference.europe,
    standings: const [
      Standing(teamId: 'm', wins: 10, goalsFor: 15, goalsAgainst: 15),
      Standing(teamId: 'k', wins: 10, goalsFor: 15, goalsAgainst: 15),
    ],
  );
  expect(level.sorted.map((s) => s.teamId), ['k', 'm']);
  expect(level.sorted.map((s) => s.conferenceRank), [1, 2]);
});
```

`a` i `b` mają tę samą różnicę (+10) i te same punkty. Dziś `standing.dart:70` na tym staje. Kolejność `b` przed `a` albo odwrotnie zależy od sortowania. Po K4 więcej bramek (`b`) jest wyżej, a przy identycznym bilansie wygrywa mniejszy `teamId`.

Nazwa: `the lottery boundary keeps the worse attack when points and goal difference match`.

```dart
test('the lottery boundary keeps the worse attack when points and goal difference match', () {
  final template = presentationTeam();
  final teams = [
    for (var i = 0; i < 30; i++)
      template.copyWith(id: 'team-${i.toString().padLeft(2, '0')}', roster: []),
  ];
  // team-10 i team-11: 20 wygranych, różnica 0. team-11 strzelił więcej.
  // Worst-first: team-10 jest gorszy i zostaje w loterii (10. miejsce od końca).
  final standings = [
    for (var i = 0; i < 30; i++)
      Standing(
        teamId: teams[i].id,
        wins: i < 10 ? i : 20,
        goalsFor: i == 11 ? 40 : 20,
        goalsAgainst: i == 11 ? 40 : 20,
      ),
  ];
  final league = LeagueState(
    teams: teams,
    currentSeason: Season(
      year: 2026,
      phase: SeasonPhase.regular,
      standings: [ConferenceStandings(conference: Conference.europe, standings: standings)],
    ),
  );
  final drafted = SeasonService().runLottery(league, saveSeed: 123);
  final lotteryIds = drafted.currentSeason.draftState!.lotteryResults.map((r) => r.teamId).toSet();
  expect(lotteryIds, contains('team-10'));
  expect(lotteryIds, isNot(contains('team-11')));
});
```

Dziś oba zespoły są nierozróżnialne dla `season_lottery.dart:34`, więc `team-11` może zająć miejsce w dziesiątce loteryjnej i dostać wagę z `draft_awards_balance.dart:52`. Test trzeba oprzeć o realny podział konferencji (loteria bierze najgorszą dziesiątkę ligi, nie konferencji). Jeśli produkcyjna loteria jest ligowa, fixture z jedną listą 30 drużyn wystarcza. Jeśli jest konferencyjna, powtórzyć bilans na granicy dziesiątki wewnątrz jednej konferencji i czytać tę konferencję. Nie zgadywać progu: asercja ma nazywać drużynę z mniejszą liczbą bramek.

Nazwa: `non-lottery draft order puts the lower-scoring tied team later`.

```dart
test('non-lottery draft order puts the lower-scoring tied team later', () {
  final result = DraftService().buildDraftOrder(tiedLeague, lotteryOfWorstTen, saveSeed: 123);
  final roundOne = result.currentSeason.draftState!.order.take(30).map((p) => p.originalTeamId).toList();
  final worse = roundOne.indexOf('team-10');
  final betterAttack = roundOne.indexOf('team-11');
  expect(worse, greaterThan(0));
  expect(betterAttack, lessThan(worse));
});
```

`tiedLeague` to ten sam stan co wyżej, `lotteryOfWorstTen` to lista 10 id już po K4 (bez `team-11`). Draft odwraca listę spoza loterii (`draft_service.dart:90`), więc drużyna z większą liczbą bramek wybiera wcześniej. Dziś przy równej różnicy kolejność po `reversed` też jest nieokreślona.

## Styl testów

Helpery już są i warto ich nie dublować: `test/helpers/fixtures/`, harnessy w `test/helpers/widgets/`, repozytoria zapisu w pamięci, oracles sztabu w `test/helpers/market/` i `test/helpers/staff/`. Pięć plików `player_list_tile_*_test.dart` dzieli `player_list_tile_harness.dart`. To jest wzorzec do naśladowania: cięcie po zachowaniu, wspólny setup w jednym pliku. Gorzej wygląda cięcie, przy którym każdy plik kopiuje budowę `GameController`.

### Co scalić

Polityka wiadomości pilnych jest rozbita na co najmniej sześć plików: `urgent_message_simulation_controller_test.dart`, `urgent_message_simulation_snapshot_test.dart`, `urgent_message_simulation_manual_progression_test.dart`, `urgent_message_inbox_handoff_test.dart`, `urgent_message_simulation_false_policy_property_test.dart`, `urgent_message_simulation_true_policy_property_test.dart`. Fałszywa i prawdziwa polityka budują ten sam `calendarFixture` i ten sam kontroler. Enum `_BatchCaller` żyje tylko w pliku true (`urgent_message_simulation_true_policy_property_test.dart:25`). Propozycja: `urgent_message_simulation_policy_test.dart` z `group('disabled')` i `group('enabled')`, jedna funkcja `pumpPolicy({required bool enabled, required _BatchCaller caller})`. Pliki widgetowe handoffu zostawić, jeśli naprawdę klikają inny ekran.

Sortowanie tabeli jest skopiowane w teście zamiast wołać produkcję: `test/balance/gameplay_rules_test.dart:26` sortuje punkty i różnicę lokalnie, a potem porównuje z `runLottery`. Po K4 ten lokalny sort ma zniknąć. Test ma czytać kolejność z `ConferenceStandings.sorted`, inaczej obie strony mogą mieć ten sam błąd i test będzie zielony.

`task39_season_service_test.dart` trzyma w jednym pliku pominięte nagrody, rollover i trenera roku. Po wyjęciu nagród do `season_awards_test.dart` zostaje rollover i trener. Archiwum `task39_..._deferred.dart.disabled` trzyma kopię tych samych testów plus play-off. Po przeniesieniu K2 archiwum tasku 39 nie powinno zostać drugim źródłem prawdy.

### Boilerplate

Dużo testów zaczyna się od `SeedDataGenerator().generateLeague(seed: …)` albo `GameFactory().create(NewGameRequest(...))` w środku `test`, bez `setUp`. Tam, gdzie liga jest tylko tłem (cap, rozwój, sztab), wystarczy `late LeagueState league; setUp(() { league = seededLeague(); });`. `seededLeague()` i `presentationTeam()` już są w `test/helpers/fixtures/`. Nowe testy K4 nie powinny kopiować 40 linii `LeagueState` z `draft_order_test.dart:20`. Warto dodać `leagueWithStandings(List<Standing> europe, {List<Standing> rest = const []})` obok `presentationTeam()`.

Testy własnościowe są w praktyce pętlą w jednym `test()`. Upadek w iteracji 7 wygląda jak upadek całego testu, bez nazwy przypadku. `for (final seed in [...]) { test('lottery weights, seed $seed', () {}); }` daje osobną pozycję w reporterze. Tak jest już w `gameplay_rules_test.dart:17`. Pliki `*_property_test.dart` z jednym `test` i pętlą w środku warto przy najbliższej edycji rozwinąć albo podpiąć pod `glados`, skoro pakiet jest w `pubspec.yaml`.

`setUp` jest rzadkie także w widgetach, które w każdym teście wołają `pumpWidget` i `pumpAndSettle`. Harness `dashboardApp` (`finance_dashboard_test.dart`) jest dobry. Brakuje mu asercji kwot (C5), nie kolejnego wrappera.

### Nazwy

`task39`, `i05_`, `Task 27` nie mówią, co jest sprawdzane. `Feature: … Property N:` w nazwach UI jest długie i przy ucięciu reportera `compact` widać prefiks, nie zachowanie. Lepiej: `substitute sheet swaps the selected player`. Mieszanina polskiego i angielskiego (C4) zostaje kosmetyczna, dopóki plik nie jest ruszany. Wyjątek: `skip:` po polsku i angielsku w jednym zdaniu utrudnia szukanie. Komunikat z `task39:297` jest po angielsku i to jest w porządku; problemem jest samo `skip`, nie język.

Nazwa `tied standings` (C3) jest myląca mocniej niż prefiks tasku, bo sugeruje pokrycie K4. Przy dotknięciu pliku zmienić ją od razu.

### Magiczne liczby

Progi capu `350000000` / `396700000` / `431700000` powtórzyć z `balance.salaryCap` (C2). Liczby po podwyżce wyprowadzić z procentu, nie wpisywać `385000000`.

Zostawić jako nazwane stałe, nie usuwać: `870` meczów i `58` kolejek (wynik 30 drużyn × 29 × 2), seedy `123`, `3901`, `3903` (przypięte do złotych dni w `schedule_generator_test.dart:22`). W nowym teście play-off nazwać je `const playoffSeed = 3903` obok komentarza „ten sam seed co archiwum task 39”. Próg dogrywki `0.55` (`season_post_match.dart:205`) nie występuje w teście. Po K1 warto jednego seeda, o którym wiadomo, że wpada w karne (`nextDouble() >= 0.55`), przypiąć z nazwy, inaczej `expect(games.any(wentToShootout))` z archiwum (`:410`) jest zależne od UUID i bywa czerwone albo puste bez zmiany reguły.

Minuty `2088` w teście bramkarza wyprowadzić: `(BalanceConfig.defaults.awards.possibleMinutes * BalanceConfig.defaults.awards.bestGkMinutesPct).ceil()`. Inaczej zmiana procentu progu cicho wykluczy obu zawodników z puli i test sprawdzi `null`, nie formułę.

### Czytelność

Pominięty test nagród ma 40 linii oczekiwań, których nikt nie wykonuje. Czytelnik myśli, że zwycięzcy są pilnowani. Lepiej krótki test idempotencji (sekcja b) niż `skip` z akapitem.

Reporter `compact` pokazuje najstarszy aktywny test (`package:test`, `CompactReporter._onStateChange`). W logu przebiegu nie ma nazw większości szybkich plików, choć licznik `+1851` obejmuje cały odkryty zestaw. Do diagnozy CI lepiej `--reporter expanded`, tak jak `scripts/test.ps1:33`. Przebieg lokalny z `compact` nie jest dowodem, że pliku nie uruchomiono.

Komentarz przy `initial_roster_replay_test.dart:29` jest szczery (UUID i timestamp poza kontraktem) i przez to niebezpieczny: ten sam UUID wszedł do klucza RNG pucharu. Po K1 dopisać w tym komentarzu, że id serii play-off do wyłączenia nie należy.

Powód na blackliście jest często kopiowany („Deferred AI or match-engine requirements”, „Mixed file; listed AI/engine cases are deferred”). Przy K2 powód jest nieprawdziwy: przypadek nie potrzebuje silnika. Nowy wpis ma nazywać jeden przypadek, tak jak robi to wpis free agency (`blacklist.json`, `deferredCases` z konkretnym zdaniem), a nie cały obszar.

## Jak `*_long.dart` i blacklista wypadają z przebiegu

Są trzy niezależne filtry. Wszystkie trzy działają.

1. Odkrywanie Darta. `flutter test` i `dart test` bez ścieżki biorą pliki kończące się na `_test.dart`. `calendar_simulation_property_long.dart` się nie załaduje. Podanie ścieżki wprost plik uruchamia. Dlatego sam suffix nie wystarcza jako zabezpieczenie, gdy ktoś doda katalog do argumentów.

2. Selektor PowerShell. `Get-TestSelection` w `scripts/test_support.ps1:54` przy profilu `standard` i `fast` zwraca tylko `*_test.dart`, przy `long` tylko `*_long.dart`. CI woła `-Profile standard` (`.github/workflows/ci.yml:38`). `scripts/test.ps1:24` dodatkowo rzuca, jeśli profil `long` wystartuje przy ustawionym `CI`. `test.ps1:39` wypisuje `LONG_NOT_RUN`, ale job się od tego nie wykłada. Preset `fast` w `dart_test.yaml:15` wyklucza tagi `slow`, `benchmark` i `integration`. CI tego presetu nie używa, więc pięć plików `test/integration/*_test.dart` w profilu standard wchodzi. To nie jest `integration_test/` na urządzeniu. Katalogu `integration_test/` nie ma.

3. Blacklista. Plik ma kończyć się na `.dart.disabled` i leżeć w `disabled/` albo, gdy `long: true`, w `long/` (`test_support.ps1:32`). Brak wpisu dla istniejącego `.disabled` i odwrotnie kończy selektor błędem, zanim ruszy `flutter test`. Aktywny test nie może importować `.disabled` (`:57`). `*_test.dart` w katalogu `long/` lub `disabled/` jest zabronione (`:47`), więc nie da się „przypadkiem” wrócić do discovery zmianą samego suffixu bez przeniesienia pliku.

Czy tak powinno zostać:

| Zbiór | Zostawić poza `standard`? | Dlaczego |
| --- | --- | --- |
| `performance/long/*measurements*`, `save_repository_baseline_long.dart` | tak | Pomiar czasu i rozmiaru na współdzielonym runnerze, budżet joba 15 min (`ci.yml:37`). |
| `simulation_worker_long.dart`, `save_size_guard_long.dart`, `season_progression_long.dart` | nie w całości | Mają asercje funkcjonalne (izolat, budżet zapisu, dojście do play-in). Przenieść asercje do `*_test.dart`, pomiar zostawić w `long`. |
| `calendar/long/*` (nawigacja, popup, property) | tak, z okresowym ręcznym przebiegiem | Dublują wolniejsze ścieżki UI. Nie zastępują K2. |
| `*_test.dart.disabled` silnika i AI | tak, do czasu przepięcia na `SimulationMatchEngine` | Odkomentowanie `MatchEngine` psuje `source_boundaries_test.dart:14`. |
| Dwa `deferredCases` play-off w tasku 39 | nie | To K2. Nie są testem wydajnościowym i nie potrzebują silnika, jeśli mecz jest podstawiony. |

Dwa `skip: !Platform.isWindows` w `test/data/long/process_cleanup_long.dart:57` i `save_recovery_integrity_long.dart:115` i tak nie chodzą na ubuntu-latest, także po włączeniu profilu `long`. Jeśli blokada katalogu zapisu ma być pilnowana, potrzebny jest odpowiednik bez WinAPI albo job Windows. Dziś ta gałąź jest martwa podwójnie: profil `long` i system.

Nie włączać profilu `long` do każdego PR. Wystarczy, że przypadki, które mówią „mistrz, izolat, rozmiar zapisu”, przestaną mieszkać wyłącznie w plikach niewidocznych dla `flutter test`.

## Kolejność robót

1. K1 i K4 (id serii, wspólny tie-break) oraz testy z sekcji a i c. Mały diff, pada na obecnym kodzie.
2. K2: przenieść dwa przypadki z archiwum do `playoff_bracket_test.dart`, zdjąć je z `blacklist.json:413`. Nie włączać reszty pliku disabled.
3. K3: albo kolumna goli straconych, albo wyzerowanie wagi, plus test „własny gol nie wybiera bramkarza” i idempotencja bez `skip`.
4. W3 i W6 (agregacja statystyk, pary terminarza) w tym samym cyklu co nagrody i terminarz, bo asercje są krótkie.
5. K5 jako nowy, krótki kontrakt `SimulationMatchEngine`, nie jako powrót tasków 15–23.
6. C1–C5 przy okazji edycji tych plików, bez osobnego PR porządkowego.
