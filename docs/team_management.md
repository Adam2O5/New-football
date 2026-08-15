# Zarządzanie zespołem

Dokument opisuje zarządzanie zespołem jako ogół obejmując status zespołu, atmosfere, zgranie oraz eveny związane z zespołem.

---

## Tabela siły ligi

Wspólna podstawa dla `teamStatus` i `expectedRank`. Jedno źródło prawdy — obie wartości wynikają z tej samej tabeli.

### Metryka

```text
teamPower = średni overall 15 najlepszych zawodników rosteru (po overall, malejąco)
```

- Liczą się **wszyscy** zawodnicy rosteru, także kontuzjowani i zawieszeni.
- Zawodnicy draftowani bez podpisanego kontraktu (`contracts.md` §9) **nie** wchodzą do wyliczenia.
- Roster poniżej 15 zawodników (skutek emerytur): brakujące miejsca liczone jako **50** overall.
- Wynik zaokrąglany do **2 miejsc po przecinku**.0

Wszystkie 30 drużyn sortowane malejąco po `teamPower` → pozycja **1–30** w tabeli siły ligi.

**Tie-break** (kolejno): wyższy `teamPower` z pełną precyzją → więcej punktów w poprzednim sezonie regularnym → niższy `totalPayroll` → `teamId` (determinizm).

### Moment przeliczania

| Kiedy | Zakres obowiązywania |
| ----- | -------------------- |
| Start nowej kariery | cały pierwszy sezon |
| Co miesiąc każdego 1 dnia miesiąca (do trade deadline) | całe okno wymian |
| **Poniedziałek tyg. 23** (trade deadline) | korekta na końcówkę sezonu i playoff |

Tabela nie jest przeliczana przy każdej wymianie — to stabilny wskaźnik okresowy, nie wskaźnik chwilowy.

---

## Team status

`teamStatus` przypisywany bezpośrednio z pozycji w tabeli siły ligi.

| Pozycja w tabeli siły | teamStatus | Liczba drużyn | Charakter | Bonus do `offerScore` (`contracts.md`) |
| --------------------- | ---------- | ------------: | --------- | -------------------------------------: |
| **1–3** | `elite` | 3 | Ścisła czołówka, okno tytułowe otwarte | **+7** |
| **4–9** | `contender` | 6 | Realny kandydat do tytułu | **+5** |
| **10–18** | `pretender` | 9 | Walka o playoff, brak przewagi | **0** |
| **19–25** | `retool` | 7 | Przebudowa przy zachowaniu rdzenia | **−3** |
| **26–30** | `rebuild` | 5 | Pełna odbudowa, priorytet młodzieży | **−5** |

Podział 3 / 6 / 9 / 7 / 5 = **30 drużyn**. Rozkład jest **stały** — w każdym sezonie dokładnie 3 drużyny są `elite`, a 5 to `rebuild`. Status jest więc zawsze relatywny wobec ligi, nigdy absolutny.

### Histereza

Zmiana statusu ograniczona do **1 tieru** na przeliczenie. Drużyna z `rebuild` nie może przeskoczyć na `contender` w jednym kroku, nawet jeśli jej `teamPower` na to wskazuje — zatrzymuje się na `retool` i awansuje dalej przy kolejnym przeliczaniu.

Wyjątek: przy starcie nowej kariery histereza nie działa (brak stanu poprzedniego).

### Gdzie jest używany

| Zastosowanie | Dokument |
| ------------ | -------- |
| `playerWant` — oczekiwania kontraktowe zawodnika | `contracts.md` §6 |
| `staffWant` — oczekiwania członka sztabu | `contracts.md` §7 |
| `playerOfferScore` / `staffOfferScore` — składnik `teamStatus` | `contracts.md` §6–7 |
| Prośba o transfer II — warunek aktywacji | ten dokument, sekcja Eventy |
| Brak awansu do playoff — kara atmosfery | ten dokument, sekcja Atmosfera |
| Wycena assetów, polityka payrollu, priorytety sztabu AI | `AI_behaviour.md` |

---

## Expected rank

`expectedRank` = **pozycja drużyny w tabeli siły ligi** (1–30) z ostatniego przeliczania.

Interpretacja: miejsce, które drużyna powinna zająć w tabeli ligowej, jeśli sezon przebiegnie zgodnie z jakością rosteru.

### Zastosowania

| Zastosowanie | Reguła | Dokument |
| ------------ | ------ | -------- |
| Wynik tygodnia lepszy / gorszy niż oczekiwany | porównanie bieżącej pozycji w tabeli ligowej z `expectedRank` | ten dokument, sekcja Atmosfera |
| Coach of the Year | `placeVsPreseasonSeed` = `expectedRank` − pozycja końcowa | `offseason.md` |
| `expectedWins` | `round(58 × (1 − (expectedRank − 1) / 29 × 0,45) × 0,5)` | `offseason.md`, `AI_behaviour.md` |

### expectedWins

Przeliczenie `expectedRank` na oczekiwaną liczbę zwycięstw w 58-meczowym sezonie:

| `expectedRank` | `expectedWins` |
| -------------: | -------------: |
| 1 | 29 |
| 5 | 27 |
| 10 | 25 |
| 15 | 23 |
| 20 | 21 |
| 25 | 18 |
| 30 | 16 |

Wartości pośrednie interpolowane liniowo. Suma po lidze ≈ liczba meczów, więc metryka jest wewnętrznie spójna.

### Próg „lepiej / gorzej niż oczekiwano"

| Różnica (`expectedRank` − pozycja bieżąca) | Ocena | Δ atmosfera / tydzień |
| -----------------------------------------: | ----- | --------------------: |
| ≥ +6 | wyraźnie lepiej | **+2** |
| +2 … +5 | lepiej | **+1** |
| −1 … +1 | zgodnie z oczekiwaniami | 0 |
| −5 … −2 | gorzej | **−1** |
| ≤ −6 | wyraźnie gorzej | **−2** |

Domyka tabelę zmian atmosfery poniżej (wiersze „Wynik tygodnia lepszy / gorszy niż oczekiwany").

---

## Atmosfera

### Co na nią wpływa

| Czynnik | Kierunek | Uwagi |
| ------- | -------- | ----- |
| **Zgranie** | wysokie ↑ / niskie ↓ | bardziej zgrany zespół ułatwia utrzymanie dobrej atmosfery |
| **Forma zespołu** | seria zwycięstw ↑, porażek ↓ | forma = wyniki z ostatnich 8 meczów (+ miejsce w tabeli vs oczekiwania) |
| **Eventy losowe** | zależne od eventu | prośby zawodników, losowe wydarzenia oraz decyzje menadżera |

### Skutki atmosfery

| Poziom | Zakres | Efekt meczowy | Dryf zgrania / tydzień | Inne efekty |
| ------ | ------ | --------------------------------------------- | ---------------- | ----------------------- | ----------- |
| Kryzys | 0–29 | ×0,95 | **−2** pkt | +25% szansy na negatywny event |
| Słaba | 30–44 | ×0,97 | **−1** pkt | +10% szansy na negatywny event |
| Neutralna | 45–69 | ×1,00  | 0 | brak modyfikatora |
| Dobra | 70–84 | ×1,02 | **+1** pkt | +10% szansy na event pozytywny |
| Świetna | 85–100 | ×1,04 | **+2** pkt | +20% szansy na event pozytywny |

### Dokładne wartości zmian atmosfery

Aktualizacja **raz na tydzień** (niedziela → poniedziałek, przy rollover) + doraźnie po eventach i meczach.

| Źródło zmiany | Δ atmosfera |
| -------------- | ----------: |
| Seria 3+ zwycięstw z rzędu | **+3** |
| Seria 3+ porażek z rzędu | **−3** |
| Wynik tygodnia lepszy niż oczekiwany (miejsce w tabeli vs `expectedRank`) | **+1 lub +2** (progi wyżej) |
| Wynik tygodnia gorszy niż oczekiwany | **−1 lub −2** (progi wyżej) |
| Walkower (nielegalny roster / brak GK) | **−15** jednorazowo |
| Mistrzostwo | **+30** jednorazowo |
| Brak awansu do playoff (gdy team status >= pretender) | **−8 lub -12 lub -15** jednorazowo |
| Eventy losowe | zależne od eventu (poniżej) |

Clamp: `atmosphere ∈ [0, 100]`.

---

## Zgranie

### Co buduje zgranie

| Czynnik | Opis |
| ------- | ---- |
| **Czas razem** | `seasonsWithTeam` + wspólne mecze w XI; nowi zawodnicy startują z karą „adaptacji” |
| **Osobowość** | kompatybilność w szatni (np. wielu `leader` / `professional` ↑; skupisko `temperamental` ↓) |
| **Wspólna narodowość** | klastry (4+) tej samej `Nationality` w XI dają bonus linków (nie wymaga całej drużyny z jednego kraju) |
| **Atmosfera** | dryf w górę/dół |

### Skutki zgrania

Zgranie modyfikuje efektywne atrybuty poprzez mnożnik.

| Zgranie | `chemistryMult` | Efekt |
| ------- | ------------------------: | ----- |
| 0–29 | 0,95 | wyraźne obniżenie |
| 30–49 | 0,98 | lekkie obniżenie |
| 50–69 | 1,00 | baseline |
| 70–84 | 1,02 | lekki boost |
| 85–100 | 1,05 | silny boost |

Wysokie zgranie **zwiększa** atrybuty; niskie **obniża**.

### Dokładne wartości zmian zgrania

Zgranie zmienia się **wolniej** niż atmosfera — to ma być bezwładny wskaźnik budowany latami, nie tygodniami.

| Źródło zmiany | Δ zgranie |
| -------------- | --------: |
| Mecz w optymalnej pozycji dla całej XI (11/11) | **+0,3** / mecz |
| Zawodnik poza optymalną pozycją w XI | **−0,4** / mecz za zawodnika |
| Nowy transfer w XI (pierwsze 5 meczów w klubie) | **−1** / mecz (kara adaptacji, zanika liniowo do 0 po 5. meczu) |
| `seasonsWithTeam` ≥ 3 dla ≥ 10 zawodników w rosterze | **+0,3** / mecz |
| Para/klaster tej samej narodowości w XI (4+ zawodników) | **+0,2** / mecz za każdy klaster (max +1,0 łącznie) |
| Sezon rollover (nowy sezon) | brak resetu globalnego — tylko nowi zawodnicy startują z `seasonsWithTeam = 0` |
| Eventy losowe | zależne od eventu (poniżej) |

Clamp: `chemistry ∈ [0, 100]`.

---

## Eventy związane z zespołem

Poniższe eventy generują wiadomość w inboksie (`docs/messages.md`) i — jeśli oznaczone jako decyzyjne — czekają na reakcję gracza (Accept / Decline / Negocjuj), zanim symulacja pójdzie dalej. AI rozwiązuje je automatycznie wg profilu (`AI_behaviour.md`).

### Prośba o więcej minut

**Aktywacja:** zawodnik z overall ≥ średnia XI drużyny lub w wieku <=26 i potencjale większym niż średnia zespołu, rozegrał &lt;25% możliwych minut w ostatnich 6 tygodniach(nie kontuzjowany/zawieszony). Szansa rolla: bazowo 3%/tydzień, 5% jeśli osobowość `ambitious`.

- **Accept (obiecujesz rolę w XI):** natychmiastowo -3; jeśli w ciągu 4 tygodni zawodnik faktycznie dostanie ≥40% minut → atmosfera +5. Jeśli obietnica złamana → **−12** atmosfera (`temperamental`/`ambitious` dodatkowo −3) i szansa 20% na złożenie szansy na transfer II.
- **Decline:** −7 atmosfera; `temperamental`/`ambitious` dodatkowo −3.
- **Ignoruj (brak reakcji do końca dnia):** traktowane jak Decline.

Roll następuje po meczu.

### Prośba o transfer I

**Aktywacja:** atmosfera drużyny &lt;40 przez 4+ tygodnie z rzędu, LUB zawodnik ma `pointValue` w top 20% ligi a klub jest w dolnej połowie tabeli. Szansa rolla: bazowo 1%/tydzień, ×2 jeśli osobowość `ambitious`. Nie dotyczy graczy o osobowości `loyal`.

- **Accept (zobowiązujesz się szukać transferu w oknie):** +3 atmosfera od razu (uspokojenie). Jeśli trade nie dojdzie do skutku do miesiąca czasu (lub końca trade deadline) → **−15** atmosfera i **-4** zgranie.
- **Decline (zatrzymujesz na siłę):** −6 atmosfera + −2 zgranie (szatnia widzi konflikt).
- **Skutek uboczny niezależnie od decyzji:** `pointValue` zawodnika spada tymczasowo o 10% (rynek wie o niezadowoleniu) do czasu rozwiązania sytuacji.

Roll następuje po meczu, tylko w trakcie okna wymian. 

### Prośba o transfer II

**Aktywacja:** klub nie osiągnął playoff mając teamStatus >= pretender lub 2 rundy playoff mając teamStatus >= contender lub 3 rundy mając teamStatus = elite. Szansa rolla: 100% dla jednego (i tylko jednego) gracza w top 11 OVR. Gracze o osobowości `loyal` nie mogą zostać wylosowani (jeśli N graczy `loyal` jest w top 11 OVR to losowany jest zawodnik z puli 11-N; jeśli wszyscy z top 11 są loyal nikt nie składa prośby o transfer). Jeśli gracz ma mniej niż rok kontraktu to zamiast prośby o transfer składa deklarację braku przedłużenia umowy (chyba, że nie jest UFA - wtedy trzeba go wymienić/nie przedłużać umowy).

- **Accept (zobowiązujesz się szukać transferu w oknie):** +3 atmosfera od razu (uspokojenie). Jeśli trade nie dojdzie do skutku do miesiąca czasu (lub końca trade deadline) → **−15** atmosfera i **-4** zgranie.
- **Decline (zatrzymujesz na siłę):** −6 atmosfera + −2 zgranie (szatnia widzi konflikt).
- **Skutek uboczny niezależnie od decyzji:** `pointValue` zawodnika spada tymczasowo o 10% (rynek wie o niezadowoleniu) do czasu rozwiązania sytuacji.

Roll następuje po zakończeniu playoff w dniu rozpoczęcia nowego okna wymian. 

### Deklaracja braku przedłużenia umowy

**Aktywacja:** yearsRemaining <= 1, dotyczy tylko graczy którzy staliby się UFA. Jeśli gracz wcześniej zadeklarował już odejście nie mże zrobić tego drugi raz. Szansa rolla: Szansa rolla: 100% - możliwe tylko jako skutek uboczny innych eventów.

- **Automatyczny (brak decyzji gracza):** Zawodnik ogłasza, że nie przedłuży kontraktu. Brak zmian w atmosferze i zgraniu.

### Konflikt w szatni

**Aktywacja:** losowy roll gdy w XI jest ≥2 zawodników `temperamental` jednocześnie ORAZ atmosfera &lt;40. Szansa: 5%/tydzień w tym stanie.

- **Interwencja menedżera (Accept — „rozmawiasz z zespołem"):** 50% szansy na +2 atmosfera, −2 zgrania jednorazowo;50% szansy na −3 atmosfera, −2 zgranie jednorazowo, zwiększona szansa na negatywne eventy o 20% na kolejne 2 tygodnie. Jeden z zawodników `temperamental` składa Prośbę o transfer.
- **Zignorowanie:** −3 atmosfera, −2 zgranie jednorazowo, zwiększona szansa na negatywne eventy o 20% na kolejne 2 tygodnie.

### Lider szatni wspiera drużynę

**Aktywacja:** losowy roll po serii 3+ zwycięstw, gdy w XI jest zawodnik z osobowością `leader`. Szansa: 15%. Cooldown: 1 miesiąc.

- **Automatyczny (brak decyzji gracza):** +4 atmosfera, +1 zgranie jednorazowo. Czysto pozytywny event budujący fabułę sezonu.

### Publiczna krytyka menedżera

**Aktywacja:** losowy roll przy atmosferze &lt;30. Jeden z graczy top 15 OVR i wieku >25 krytykuje publicznie menedżera. Szansa: 8%/tydzień w tym stanie.

- **Publiczna odpowiedź:** -1 atmosfera, -1 zgranie.
- **Kara dyscyplinarna:** −2 atmosfera, -2 atmosfera, szansa powtórzenia eventu maleje o 50%.
- **Brak reakcji:** -1 atmosfera, -1 zgranie, szansa powtórzenia eventu rośnie o 50%.

---