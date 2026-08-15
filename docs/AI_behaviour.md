# Zachowania AI

Dokument definiuje kompletny model decyzyjny drużyn AI. W wersji **V1 istnieje jeden model AI** — bez poziomów trudności i bez profili menedżera.

Powiązane: `team_management.md`, `salary_cap.md`, `contracts.md`, `trades.md`, `draft.md`, `offseason.md`, `staff.md`, `squad_management.md`, `player_management.md`, `tactics.md`, `matchday_model.md`, `game_calendar.md`, `messages.md`.

Status: **kanon reguł**. Wartości liczbowe zgodnie z `general_rules.md` trafiają do `/balance`.

---

## 1. Zasady nadrzędne

### 1.1 Symetria reguł

AI podlega **dokładnie tym samym regułom** co gracz. Nie ma żadnych wyjątków systemowych.

| Obszar | Reguła wspólna | Źródło |
| ------ | -------------- | ------ |
| Salary cap | 350 000 000 €, aprony 396,7M / 431,7M | `salary_cap.md` |
| Staff cap | 15 000 000 €, 6 slotów | `salary_cap.md`, `staff.md` |
| Roster | 20–30, bez minimum GK | `squad_management.md` |
| Wymiany | matching 125% + 500k, Stepien, max 3 picki / 5 zawodników, tylko 2 drużyny | `trades.md` |
| Wyjątki kontraktowe | Rookie scale, Bird, Early Bird, Non-Bird, QO, Veteran raise 8% | `contracts.md` |
| Rytm FA phase I | 10 godzin, 1 oferta zawodnik + 1 staff / klub / godzinę | `contracts.md` |
| Przedłużenia | 1 oferta na podmiot na dzień, wt–niedz tyg. 46 | `contracts.md` |
| Wiedza o prospektach | wyłącznie z własnego scouta (tiery) | `staff.md` |
| Walkower | 0–3 przy nielegalnym rosterze | `squad_management.md` |
| Emerytury | tabela P dla 33+ | `offseason.md` |
| **Brak zwolnień** | nie można zwolnić zawodnika ani sztabu; niekorzystny kontrakt tylko wymianą | `salary_cap.md` |
| **NTC** | próg + roll 20% + zgoda przy wymianie | `trades.md` |
| `teamStatus` / `expectedRank` | tabela siły ligi (średni OVR top 15) | `team_management.md` |

**AI nie ma dostępu do ukrytych danych.** Nie widzi `injuryProne`, `determination`, `overallProgress`, `growthRate` ani `developmentOutcome` zawodników innych klubów. Prospektów ocenia wyłącznie przez tiery własnego scouta. Własnych zawodników zna tak samo jak gracz zna swoich.

### 1.2 Kalibracja: „średnio-trudne"

Docelowy charakter AI: **kompetentny, przewidywalny w intencjach, bez skrajności**.

| Cecha | Ustawienie V1 |
| ----- | ------------- |
| Jakość wyceny | analiza danych, blisko optymalna |
| Szum decyzyjny | mały, ale obecny (§2.5) |
| Marża przy wymianach | oczekuje **+4…+12%** nadwyżki, nie +25% |
| Współpraca z graczem | realna — fair trade zwykle przechodzi |
| Blokowanie gracza | brak celowego blokowania; konkurencja wynika z własnych potrzeb |
| Skrajne zagrania | brak (żadnych all-in dumpów, żadnych 5-letnich kontraktów dla 35-latków) |
| Adaptacja | reaguje na wyniki i potrzeby, nie na tożsamość rywala |

### 1.3 Brak biasu przeciw graczowi

AI **nie traktuje gracza inaczej niż innej drużyny AI**. Każda reguła w tym dokumencie stosuje się jednakowo do relacji AI↔gracz i AI↔AI. Jedyne różnice to techniczne: gracz odpowiada przez UI, AI natychmiast.

### 1.4 Determinizm

```text
aiSeed = hash(saveSeed, seasonYear, weekNumber, teamId, decisionType)
```

Każda decyzja AI jest powtarzalna dla tego samego stanu ligi. Wymagane do testów balansu i do spójności zapisu.

---

## 2. Fundament oceny

### 2.1 teamStatus i expectedRank

Definicja kanoniczna znajduje się w **`team_management.md`** (sekcje „Tabela siły ligi", „Team status", „Expected rank") i dotyczy wszystkich 30 drużyn, także drużyny gracza. AI **nie ma własnej metryki** — używa dokładnie tych samych wartości co UI gracza.

Skrót na potrzeby tego dokumentu:

| Pojęcie | Definicja |
| ------- | --------- |
| `teamPower` | średni overall **15 najlepszych** zawodników rosteru |
| `expectedRank` | pozycja **1–30** w tabeli ligi posortowanej malejąco po `teamPower` |
| `teamStatus` | tier przypisany z `expectedRank` |

| `expectedRank` | `teamStatus` | Bonus do `offerScore` |
| -------------- | ------------ | --------------------: |
| 1–3 | `elite` | +7 |
| 4–9 | `contender` | +5 |
| 10–18 | `pretender` | 0 |
| 19–25 | `retool` | −3 |
| 26–30 | `rebuild` | −5 |

Przeliczanie: wtorek tyg. **44** i poniedziałek tyg. **23**. Histereza: maks. **1 tier** na przeliczenie.

**Konsekwencja projektowa:** rozkład tierów jest stały (3/6/9/7/5), więc status jest zawsze relatywny. W każdym sezonie dokładnie 5 drużyn działa w trybie `rebuild` i 3 w trybie `elite` — liga nigdy nie osuwa się w stan, w którym wszyscy są kontenderami albo wszyscy odbudowują.

### 2.2 Potrzeby pozycyjne

Docelowa struktura rosteru (suma = 25, środek pasma 20–30):

| Grupa | Pozycje | Min | Target | Max |
| ----- | ------- | --: | -----: | --: |
| Bramkarze | `gk` | 2 | 3 | 4 |
| Środkowi obrońcy | `cb` | 3 | 4 | 5 |
| Boczni obrońcy | `lb`, `rb`, `lwb`, `rwb` | 3 | 4 | 6 |
| Środek pola | `cdm`, `cm` | 4 | 5 | 7 |
| Ofensywni pomocnicy | `cam` | 1 | 2 | 3 |
| Skrzydłowi | `lw`, `rw` | 3 | 4 | 6 |
| Napastnicy | `st` | 2 | 3 | 4 |

```text
needScore(grupa) = gapPenalty + qualityGap

gapPenalty:
  count < min      → 40 + (min − count) × 15
  count < target   → (target − count) × 8
  count >= target  → 0
  count >= max     → −12

qualityGap = max(0, ligaMedianaOvrGrupy − najlepszyOvrWGrupie) × 1,5
```

`needScore ≥ 40` = **luka krytyczna** (min-gap). Uruchamia agresywniejsze progi w wymianach i FA.

### 2.3 Wycena zawodnika

Baza: `pointValue` z `player_management.md` (−1000 … 1000).

```text
assetValue(zawodnik) = pointValue × statusAgeMult × needMult × contextMult
```

**`statusAgeMult`** — ta sama gwiazda jest warta różnie dla różnych klubów:

| teamStatus | ≤ 23 | 24–29 | 30–32 | 33+ |
| ---------- | ---: | ----: | ----: | --: |
| `rebuild` | ×1,30 | ×1,00 | ×0,70 | ×0,45 |
| `retool` | ×1,20 | ×1,05 | ×0,85 | ×0,60 |
| `pretender` | ×1,05 | ×1,10 | ×1,00 | ×0,85 |
| `contender` | ×0,95 | ×1,15 | ×1,10 | ×0,95 |
| `elite` | ×0,90 | ×1,15 | ×1,15 | ×1,00 |

**`needMult`:**

| Sytuacja pozycyjna | Mnożnik |
| ------------------ | ------: |
| Luka krytyczna (`needScore ≥ 40`) | ×1,18 |
| Poniżej target | ×1,08 |
| Na target | ×1,00 |
| Na max lub powyżej | ×0,88 |

**`contextMult`:**

| Warunek | Mnożnik |
| ------- | ------: |
| Zawodnik złożył prośbę o transfer | ×0,90 (zgodnie z `team_management.md`) |
| Kontuzja Major w trakcie | ×0,80 |
| `yearsRemaining` = 1 i nie jest UFA-blokowany | ×0,92 |
| Rookie scale, rok 1 | ×1,06 |
| NTC aktywna (`trades.md`) | ×0,92 — ryzyko odmowy zgody |
| Pensja > 1,5 × `estimatedSalary` i `yearsRemaining ≥ 3` | ×0,85 — kontrakt-kotwica, nie ma jak go zdjąć poza wymianą |

Rozdzielenie `pointValue` (obiektywna wartość rynkowa) od `assetValue` (wartość dla konkretnego klubu) jest kluczowe — dzięki temu wymiany AI↔AI mają sens: obie strony mogą realnie zyskać.

### 2.4 Wycena picków

Picki z przypisanym `pickNumber` (po loterii):

| Slot | pointValue |
| ---- | ---------: |
| R1 #1 | 900 |
| R1 #2–3 | 780 |
| R1 #4–7 | 650 |
| R1 #8–14 | 500 |
| R1 #15–22 | 380 |
| R1 #23–30 | 290 |
| R2 #31–45 | 180 |
| R2 #46–60 | 120 |
| R3 #61–75 | 70 |
| R3 #76–90 | 40 |

Picki przyszłe (bez `pickNumber`): slot projektowany z `expectedRank` właściciela (`team_management.md`). Kolejność draftu jest odwrotna do tabeli, więc:

```text
projectedSlot(runda, właściciel) = (31 − expectedRank) + (runda − 1) × 30
futurePickValue = slotValue(projectedSlot) × 0,90^(yearsAhead − 1) × uncertaintyMult
```

Przykłady: `expectedRank` 30 (najsłabszy) → R1 slot **#1**; `expectedRank` 1 (najmocniejszy) → R1 slot **#30**; `expectedRank` 15 → R2 slot **#46**.

| yearsAhead | Mnożnik dyskonta | `uncertaintyMult` |
| ---------: | ---------------: | ----------------: |
| 1 | ×1,00 | ×1,00 |
| 2 | ×0,90 | ×0,96 |
| 3 | ×0,81 | ×0,92 |
| 4 | ×0,73 | ×0,88 |
| 5 | ×0,66 | ×0,84 |
| 6 | ×0,59 | ×0,80 |
| 7 | ×0,53 | ×0,76 |

**Wygładzenie loterii:** dla drużyn z `expectedRank ≥ 21` (dolna dziesiątka, uczestnicy loterii — `draft.md`) projekcja slotu R1 nie jest punktowa. AI używa wartości oczekiwanej z wag loterii:

| `expectedRank` | Projektowany slot R1 (wartość oczekiwana) |
| -------------: | ---------------------------------------: |
| 30 | 3,5 |
| 29 | 3,8 |
| 28 | 4,1 |
| 27 | 4,6 |
| 26 | 5,2 |
| 25 | 5,9 |
| 24 | 6,7 |
| 23 | 7,6 |
| 22 | 8,5 |
| 21 | 9,4 |

Wartość picka interpolowana między sąsiednimi progami tabeli slotów. Dzięki temu pick najsłabszej drużyny nie jest wyceniany jak gwarantowana „jedynka" — co jest zgodne z tym, że loteria nie daje gwarancji (`draft.md`).

**Premia rebuildu:** `rebuild` i `retool` wyceniają picki R1 **×1,15**; `contender` i `elite` **×0,88**. To naturalnie napędza handel picki↔gwiazdy między drużynami o różnym statusie.

**Prawa do niepodpisanego draftowanego zawodnika** (`contracts.md` §9): wycena jak pick z odpowiedniego slotu × 0,85.

### 2.5 Szum decyzyjny

AI nie jest doskonała. Do każdej wyceny pakietu doliczany jest szum:

```text
evaluationNoise ~ N(0; 4%) od wartości pakietu
```

Dodatkowo w wyborach dyskretnych (draft, cel FA, formacja) stosowany szum punktowy — wartości w odpowiednich sekcjach. Szum 4% to celowo mało: AI ma być kompetentna, ale nie idealnie odczytywalna.

---

## 3. Planowanie sezonu

### 3.1 Docelowy payroll

Ponieważ w V1 nie ma budżetu operacyjnego ani konsekwencji podatku (`salary_cap.md`), jedynym kosztem apronów jest **utrata elastyczności**. AI wycenia to jako `apronPenalty`:

| Poziom payrollu | Pasmo docelowe | `apronPenalty` | Polityka |
| --------------- | -------------- | -------------: | -------- |
| `rebuild` | 60–85% capu (210–298M) | — | nigdy powyżej capu |
| `retool` | 80–100% (280–350M) | — | nigdy powyżej capu |
| `pretender` | 92–105% (322–368M) | 40 pkt | 1st apron tylko przy realnym rdzeniu playoff |
| `contender` | 100–113% (350–396M) | 25 pkt | 1st apron dozwolony |
| `elite` | 105–123% (368–431M) | 15 pkt | między apronami dozwolone |

`apronPenalty` odejmowany od `assetValue` transakcji, która przenosi drużynę na wyższy poziom. Wejście **powyżej 2nd apron** dozwolone tylko przy `elite` i tylko z prawdopodobieństwem **20%** przy realnej szansie na tytuł (najlepszy `expectedRank` w swojej konferencji).

### 3.2 Plan roczny AI

| Tydzień | Działanie |
| ------- | --------- |
| 44 (wt) | Przeliczenie tabeli siły ligi → `teamStatus` / `expectedRank`, aktualizacja `needScore` |
| 44 (śr) | Reakcja na emerytury — plan uzupełnienia rosteru |
| 44 (pt) | Loteria — aktualizacja wyceny własnych picków |
| 44–47 | Faza wymian offseason (§5.4) |
| 45 (pon) | Scout Report → assign Combine (§7.3) |
| 46 (pon) | Draft (§6) |
| 46 (wt–niedz) | Przedłużenia (§8.1) |
| 47 | FA phase I (§8.2) |
| 47 → 1 | FA phase II, domykanie rosteru do 20–30 (§9.1) |
| 1–23 | Sezon: lineupy, taktyka, wymiany, eventy |
| 23 (pon) | Deadline — ostatnia fala wymian, korekta `teamStatus` |
| 24–29 | Sezon bez wymian; rotacja pod playoff |
| 30–43 | Play-in / playoff — tryb „best XI" (§4.3) |

---

## 4. Matchday

### 4.1 Wybór jedenastki

```text
playerMatchScore = effectiveOvrForSlot
                 × formMult          // 0,90 … 1,12 (player_management.md)
                 × staminaReadiness
                 × roleFitBonus
                 × availabilityGate
```

| `staminaReadiness` | Stamina |
| -----------------: | ------- |
| 1,00 | 80–100 |
| 0,94 | 60–79 |
| 0,82 | 40–59 |
| 0,60 | 0–39 |

| Czynnik | Wartość |
| ------- | ------: |
| `roleFitBonus` — optymalna rola | ×1,03 |
| `effectiveOvrForSlot` — obca pozycja | ×0,90 |
| `availabilityGate` — kontuzja / zawieszenie | ×0 |

Algorytm: przypisanie zachłanne do slotów formacji, potem 2 przebiegi wymiany par poprawiających sumę.

**Reguła twarda:** AI **zawsze** wystawia zawodnika z `Position.gk` w bramce, jeśli jakikolwiek zdolny bramkarz jest w rosterze. Kara ~0–5 (`matchday_model.md`) jest traktowana jako niedopuszczalna.

### 4.2 Rotacja

| Warunek | Decyzja | P |
| ------- | ------- | -: |
| Kolejny mecz w ≤ 3 dni i stamina < 65 | ława | 80% |
| Stamina < 45 | ława | 95% |
| Mecz bez znaczenia (matematycznie rozstrzygnięty, tyg. 27–29) | odpoczynek zawodników z `injuryProne` ≥ 7 | 60% |
| Zawodnik po powrocie z kontuzji Major, pierwszy tydzień | ograniczone minuty (ława lub < 60 min) | 70% |
| Playoff, stamina ≥ 55 | best XI niezależnie od zmęczenia | 90% |

### 4.3 Wybór formacji

```text
formationFitScore = Σ (najlepszy dostępny playerMatchScore na slot) / liczbaSlotów
```

AI wybiera z 3 formacji o najwyższym `formationFitScore`, ważąc dodatkowo matchup z `tactics.md`.

**Kontr-formacja:** po **≥ 2** meczach przeciwko danemu przeciwnikowi AI zapamiętuje jego najczęstszą rodzinę formacji. Wybiera wtedy formację z dodatnim ΔM/ΔA wobec tej rodziny.

| Parametr | Wartość |
| -------- | ------: |
| P(zastosowania kontr-formacji) | **65%** |
| Minimalna liczba meczów w pamięci | 2 |
| Okno pamięci | 2 sezony |
| Waga matchupu vs fit | 35% / 65% |

Dotyczy **każdego** przeciwnika, w tym drużyny gracza — bez wyróżniania.

### 4.4 Ustawienia taktyczne

Baza z różnicy siły (średni OVR XI):

| Sytuacja | Tempo | AttackWidth | DefensiveLine | Pressing |
| -------- | ----- | ----------- | ------------- | -------- |
| Przewaga ≥ +12 | `balanced` | `wide` | `high` | `high` |
| Przewaga +5…+11 | `balanced` | `wide` | `normal` | `high` |
| Wyrównany −4…+4 | `balanced` | `balanced` | `normal` | `medium` |
| Strata −5…−11 | `fast` | `balanced` | `deep` | `low` |
| Strata ≤ −12 | `slow` | `narrow` | `deep` | `low` |

Korekty z tabel matchupów `tactics.md` stosowane z P = **70%** (nie zawsze — AI ma być czytelna, ale nie mechaniczna).

Stałe fragmenty: AI ustawia `cornersAttack` / `freeKicks` / `penalties` na **65**, jeśli `teamAerialAtk ≥ 68` (`matchday_model.md` §7.6) lub w XI jest zawodnik z `shooting ≥ 82`; w przeciwnym razie **50**. `cornersDefense` = **60** przy `teamAerialDef ≥ 68`, inaczej 50.

### 4.5 Role

AI przypisuje rolę optymalną zawodnika (bonus ×1,03), jeśli jest zgodna z kierunkiem taktycznym. Przy konflikcie:

| Nastawienie | Preferencja ról |
| ----------- | --------------- |
| Faworyt / ofensywne | role z dodatnim Δatk (`attackingFullBack`, `mezzala`, `shadowStriker`, `winger`) |
| Wyrównane | role optymalne zawodników, bez korekty |
| Underdog / defensywne | role z dodatnim Δdef (`noNonsenseCentreBack`, `anchorMan`, `defensiveFullBack`, `ballWinning`) |

P(odejścia od roli optymalnej na rzecz kierunku taktycznego) = **45%**.

### 4.6 Ławka

Kompozycja 7 miejsc: **1 GK + 2 DEF + 2 MID + 2 ATK**. Przy braku zawodników na slot — najwyższy `playerMatchScore` z dostępnych.

### 4.7 Decyzje w trakcie meczu

Zgodnie z `matchday_model.md` §11.5, AI decyduje w tych samych okienkach co gracz (limit **5 zmian**, **3 okna** + przerwa).

| Trigger | Akcja | P |
| ------- | ----- | -: |
| Kontuzja zawodnika | zmiana | 100% |
| Stamina < 45 i zmiennik w zasięgu 4 OVR | zmiana | 85% |
| Stamina < 35 | zmiana niezależnie od jakości zmiennika | 95% |
| Rating < 5,0 po 60' | zmiana | 40% |
| Zawodnik na żółtej, pressing `high`/`gegenpressing`, po 70' | zmiana | 30% |
| Przegrywa 1 golem, od 65' | 1 zmiana ofensywna | 70% |
| Przegrywa 2+ golami, od 60' | 2 zmiany ofensywne | 80% |
| Wygrywa 1 golem, od 78' | 1 zmiana defensywna | 55% |
| Wygrywa 2+ golami, od 70' | zmiana odciążająca kluczowego zawodnika | 60% |
| Gra w 10 | rekonfiguracja XI + `DefensiveLine.deep` | 100% |

Korekta taktyki poza przerwą (koszt −2 cohesion na 10 min): stosowana tylko przy stracie 2+ goli po 70' — P = **50%**.

---

## 5. Wymiany

### 5.1 Ocena oferty

```text
inValue  = Σ assetValue(assety otrzymywane)
outValue = Σ assetValue(assety oddawane)
netValue = inValue − outValue − apronPenalty(jeśli podnosi poziom)

surplusPct = netValue / max(100; outValue) × 100%
surplusPct += evaluationNoise    // N(0; 4 pp)
```

Korekty progowe:

| Warunek | Przesunięcie progu |
| ------- | -----------------: |
| Oferta zapełnia lukę krytyczną (`needScore ≥ 40`) | **−8 pp** |
| Oferta oddaje ostatniego zawodnika z pozycji min | **+12 pp** |
| Partner z tej samej konferencji, obaj `contender`+ | **+10 pp** |
| Zawodnik oddawany złożył prośbę o transfer (zaakceptowaną) | **−10 pp** |
| Po deadline < 2 tygodnie i luka krytyczna | **−6 pp** |

### 5.2 Decyzja

| `surplusPct` | Accept | Counter | Reject | Hard reject |
| -----------: | -----: | ------: | -----: | ----------: |
| ≥ +12% | **95%** | 5% | — | — |
| +4% … +12% | **70%** | 30% | — | — |
| −4% … +4% | — | **60%** | 40% | — |
| −15% … −4% | — | 15% | **85%** | — |
| −30% … −15% | — | — | 70% | **30%** |
| < −30% | — | — | — | **100%** |

**Hard reject** = blokada rozmów z tym klubem na **30 dni** (spójnie z `contracts.md` §5).

### 5.3 Kontroferty AI

Gdy AI wybiera Counter, buduje pakiet celujący w `surplusPct` = **+8%** dla siebie, minimalnie modyfikując oryginalną propozycję.

| Runda kontroferty | Cel `surplusPct` | P(hard reject zamiast kolejnej rundy) |
| ----------------: | ---------------: | ------------------------------------: |
| 1 | +10% | 0% |
| 2 | +6% | 15% |
| 3 | +2% | 35% |
| 4 | — | **100%** (koniec rozmów) |

Maksymalnie **3 kontroferty** na jedną negocjację, spójnie z modelem kontraktowym.

### 5.4 Oferty AI → gracz

AI ocenia roster gracza raz w tygodniu w oknie wymian i może złożyć ofertę.

| Parametr | Wartość |
| -------- | ------: |
| P(oferta) na drużynę AI na tydzień — sezon regularny | **2,0%** |
| P(oferta) — offseason (tyg. 44–47) | **4,5%** |
| P(oferta) — okno deadline (tyg. 20–23) | **5,0%** |
| Cooldown po dowolnej ofercie tej samej drużyny | **3 tygodnie** |
| Cooldown po hard reject gracza | **4 tygodnie** |
| Limit ofert do gracza łącznie na tydzień | **3** |
| Cel `surplusPct` oferty startowej | **+10%** |
| Minimum, na jakie AI zejdzie po kontrofertach | **+2%** |

Oczekiwany wolumen: **~12–20 ofert do gracza na sezon**. Wystarczająco, by rynek żył, za mało by zaspamować inbox.

**Wybór celu:** AI szuka zawodnika gracza, dla którego `assetValue(AI) − assetValue(gracz, szacowane) > 0`. Szacowanie wartości dla gracza opiera się na jawnych danych (`pointValue`, wiek, kontrakt, głębokość pozycji gracza) — AI nie zna ukrytych atrybutów.

Każda oferta przechodzi pełną walidację (`trades.md`) **przed** wysłaniem. Gracz nigdy nie dostaje oferty niemożliwej do wykonania.

### 5.5 Wymiany AI ↔ AI

Osobny silnik uruchamiany raz w tygodniu w oknie wymian.

| Parametr | Wartość |
| -------- | ------: |
| Losowanych par kandydatów na tydzień | **12** |
| Pakietów testowanych na parę | do **6** |
| Warunek wykonania | `surplusPct ≥ +2%` **dla obu stron** |
| Limit wymian na drużynę AI na tydzień | **2** |
| Limit wymian na drużynę AI na sezon | **6** |
| Oczekiwane wymiany AI↔AI — sezon regularny | **0,8 / tydzień** |
| Oczekiwane wymiany AI↔AI — offseason (44–47) | **2,0 / tydzień** |
| Oczekiwane wymiany AI↔AI — deadline (21–23) | **3,0 / tydzień** |

Suma roczna: **~30–35 wymian AI↔AI**.

Obustronna korzyść jest osiągalna, bo `assetValue` różni się przez `statusAgeMult` i `needMult` — `rebuild` chętnie odda 30-latka za pick, `contender` odwrotnie.

**`tradeAppetite`** decyduje, czy drużyna wchodzi do puli par:

```text
tradeAppetite = 0,35 × maxNeedScore / 100
              + 0,25 × surplusPositionPressure
              + 0,20 × deadlineProximity
              + 0,20 × injuryPressure
```

Próg wejścia do puli: `tradeAppetite ≥ 0,30`. Po zaakceptowanej prośbie o transfer `tradeAppetite` dla danego zawodnika **×3** na 4 tygodnie.

### 5.6 Ograniczenia i guardraile

| Reguła | Wartość |
| ------ | ------- |
| Walidacja cap / apron / matching | zawsze, przed submitem |
| Reguła Stepiena | zawsze sprawdzana |
| Roster po wymianie 20–30 (z wyjątkiem < 20 z `trades.md`) | zawsze |
| AI nie oddaje więcej niż **2** picki R1 w 3 kolejnych latach | twarda reguła |
| AI z `rebuild`/`retool` nie oddaje picków R1 za zawodników 30+ | twarda reguła |
| NTC — roll zgody zawodnika | wg `trades.md`: `P(zgoda) = 55% + statusModifier + contextModifier`, clamp 10–95% |
| NTC — po odmowie | AI respektuje **30-dniową** blokadę na tego zawodnika i ten klub |
| Zwolnienia | **niedostępne** — AI nie ma tej opcji, tak jak gracz (`salary_cap.md`) |
| Hamulec superteamu | jeśli `teamPower` drużyny > średnia ligi + 12, jej `tradeAppetite` na dodawanie gwiazd ×0,5 |

Hamulec superteamu to **preferencja AI**, nie wyjątek regulaminowy — gracz nie jest nim objęty, bo sam podejmuje decyzje.

**NTC w planowaniu:** AI przed złożeniem oferty sprawdza `P(zgoda)`. Jeśli wychodzi poniżej **35%**, rezygnuje z celu i szuka alternatywy — P = **70%**. Dzięki temu nie zasypuje gracza ofertami, które i tak zostaną zablokowane przez zawodnika.

### 5.7 Deadline

Poniedziałek tyg. **23**: ostatni dzień wymian. W tygodniach 21–23 AI stosuje:

| Zmiana | Wartość |
| ------ | ------: |
| Mnożnik `tradeAppetite` | ×1,8 |
| Przesunięcie progu akceptacji przy luce krytycznej | −6 pp |
| `contender`/`elite` — gotowość oddania picka R2/R3 ponad wycenę | +10% |
| `rebuild`/`retool` — sprzedaż zawodników 30+ z wygasającym kontraktem | P = 45% |

---

## 6. Draft

### 6.1 Board AI

AI buduje własny board **wyłącznie z wiedzy swojego scouta** (tiery z `staff.md`).

```text
aiProspectScore = 0,55 × estOvrMid
                + 0,45 × (estPotentialStars × 12)
                + needBonus
                + N(0; 3,5)
```

| Źródło danych | Zachowanie AI |
| ------------- | ------------- |
| Tier osiągnięty | używa danych scouta (zakresy, środek przedziału) |
| Tier nieosiągnięty | używa rangi mock draftu jako proxy + szum ±8 pozycji |
| Brak scouta (0★) | wyłącznie mock finalny + szum ±14 pozycji |

`needBonus`:

| Sytuacja | Bonus |
| -------- | ----: |
| Luka krytyczna | **+8** |
| Poniżej target | **+4** |
| Na target | 0 |
| Na max | **−6** |

Klub bez scouta drafuje wyraźnie słabiej — dokładnie tak jak gracz bez scouta. Symetria informacyjna zachowana.

### 6.2 Decyzja o picku

AI wybiera prospekta z najwyższym `aiProspectScore` wśród dostępnych. Szum 3,5 pkt powoduje, że AI sporadycznie sięga po zawodnika nieoczywistego — bez skrajnych pomyłek.

**Bramkarze:** jeśli AI ma < 2 bramkarzy w rosterze i jest po picku #45, `needBonus` dla `gk` rośnie do **+20**.

### 6.3 Wymiany pickami w trakcie draftu

| Parametr | Wartość |
| -------- | ------: |
| P(AI proponuje trade-up) na drużynę na draft | **8%** |
| Warunek | prospekt z top-5 własnego boardu dostępny ≥ 4 picki dalej niż projekcja |
| Cel `surplusPct` dla oddającego pick | +5% |
| P(AI proponuje trade-down) | **4%** |
| Warunek trade-down | board AI nie ma nikogo z `aiProspectScore` > próg dla danego slotu |

Oferty trade-up mogą trafić do gracza, jeśli gracz ma pick w oknie zainteresowania — traktowane jak zwykła oferta wymiany (§5.1–5.3).

### 6.4 Kontrakty dla draftowanych

Zgodnie z `contracts.md` §9 klub nie musi podpisywać draftowanego zawodnika.

| Runda | P(AI podpisuje od razu) | Warunek |
| ----- | ----------------------: | ------- |
| R1 | **100%** | roster < 30 |
| R2 | **85%** | roster < 29 |
| R3 | **55%** | roster < 28 i `needScore` pozycji > 0 |

Niepodpisany zawodnik pozostaje assetem (nie liczy się do rosteru). AI podpisuje go później, gdy zwolni się miejsce — P = **35%/tydzień** w oknie FA.

### 6.5 Niedraftowani

30 prospektów niewybranych trafia do FA (`draft.md`).

| Warunek | P(AI składa ofertę) |
| ------- | ------------------: |
| Luka krytyczna na pozycji prospekta i roster < 26 | **60%** |
| Poniżej target i roster < 24 | **30%** |
| Roster < 20 (przymus) | **95%** |
| Pozostałe przypadki | **5%** |

Oferta zawsze na poziomie `minPlayerSalary` (1M) z kontraktem 2-letnim.

---

## 7. Skauting

### 7.1 Przypisanie scouta

Od wtorku tyg. **46** AI przypisuje scouta do prospektów klasy N+1 do limitu `maxWatched = round(4 + Coverage × 6)`.

| Parametr | Wartość |
| -------- | ------: |
| Wykorzystanie limitu Coverage | **100%** |
| Dobór wg rangi mock wstępnego | **70%** obserwowanych |
| Dobór wg potrzeb pozycyjnych | **30%** obserwowanych |

Przy braku scouta (slot pusty) AI nie ma watchlisty — drafuje z mocka.

### 7.2 Aktualizacja watchlisty

AI nie wymienia obserwowanych w trakcie roku (scouting jest ciągły, `staff.md`). Wyjątek: jeśli prospekt awansuje o **> 20 pozycji** w mocku i nie jest obserwowany, AI podmienia najniżej ocenianego obserwowanego — P = **40%** na miesięczny raport.

### 7.3 Assign na Combine

Scout Report, poniedziałek tyg. **45**. Limit = **½ Coverage** (w dół).

Wybór: prospekty z **największą niepewnością** wśród top targets — czyli te, dla których AI ma tier < 5 i `aiProspectScore` w top połowie watchlisty. Combine ujawnia optymalną rolę i poprawia oszacowanie `injuryProne` / `determination` (`offseason.md`).

---

## 8. Kontrakty i FA

### 8.1 Przedłużenia (tyg. 46, wt–niedz)

6 dni, 1 oferta na podmiot na dzień.

Kolejność priorytetów AI:

| # | Cel | Warunek |
| - | --- | ------- |
| 1 | Rookie Extension | zawodnik w 2. roku rookie scale, `potentialStars ≥ 3,5` |
| 2 | Full Bird Rights | `seasonsWithTeam ≥ 3`, zawodnik w top-11 OVR |
| 3 | Early Bird Rights | `seasonsWithTeam = 2`, `assetValue > 150` |
| 4 | Veteran Extension | `assetValue > 0`, wiek ≤ 32 |
| 5 | Non-Bird | tylko przy luce krytycznej |

| Parametr | Wartość |
| -------- | ------: |
| Docelowy `playerOfferScore` | **72** |
| Maksymalny `playerOfferScore` (górna granica przepłacenia) | **85** |
| AI nie przedłuża, jeśli `assetValue` | **< 0** |
| AI nie przedłuża zawodnika 33+ powyżej | 1 rok |
| Reakcja na counter zawodnika — P(podniesienia oferty) | **70%** przy `assetValue > 200`, **35%** przy `assetValue` 0–200 |
| Maksymalna liczba rund negocjacji | **3** |

Reguła z `contracts.md` (zawodnik bez oczekiwanych minut nie chce przedłużać) dotyczy AI tak samo — AI **traci** takich zawodników, jeśli ich nie grała.

### 8.2 FA phase I (tyg. 47, 10 godzin)

Limit: 1 oferta zawodnik + 1 oferta staff na klub na godzinę.

Wishlist budowana raz przed startem: `priority = needScore × 0,5 + assetValue × 0,5`.

| Godzina | Docelowy `playerOfferScore` | P(klub składa ofertę w tej godzinie) |
| ------: | --------------------------: | -----------------------------------: |
| 1 | 70 | 65% |
| 2 | 70 | 70% |
| 3 | 72 | 70% |
| 4 | 74 | 75% |
| 5 | 74 | 75% |
| 6 | 76 | 80% |
| 7 | 78 | 80% |
| 8 | 80 | 85% |
| 9 | 82 | 85% |
| 10 | 88 | 95% jeśli roster < 20, inaczej 40% |

**Konkurencja z graczem:** jeśli cel AI ma już inną ofertę (informacja publiczna w modelu FA), AI podnosi docelowy `offerScore` o **+6** z prawdopodobieństwem **55%**. Bez świadomego blokowania — AI po prostu konkuruje o zawodnika, którego potrzebuje.

**Guardraile przeciw psuciu rynku:**

| Reguła | Wartość |
| ------ | ------: |
| Maksymalna pensja | **1,35 ×** `expectedSalary` |
| Maksymalna długość | `expectedLength` **+ 1 rok** |
| Nigdy powyżej `maxPlayerSalary` | 60M |
| AI nie podpisuje zawodnika na pozycji `count ≥ max` | P = 5% |
| AI nie podpisuje zawodnika 33+ na > 2 lata | twarda reguła |

### 8.3 FA phase II (pon tyg. 48 → niedz tyg. 45)

Bez limitu ofert, odpowiedź w 2–4 dni.

| Parametr | Wartość |
| -------- | ------: |
| Docelowy `playerOfferScore` | **68** |
| Częstotliwość ofert na drużynę AI | max **2 / tydzień** |
| Warunek aktywności | `needScore ≥ 20` lub roster < 22 |
| Przy rosterze < 20 | **codzienne** oferty na `minPlayerSalary` do naprawienia rosteru |

### 8.4 RFA

| Decyzja | Reguła | P |
| ------- | ------ | -: |
| Złożenie QO | `pointValue ≥ 120` lub pozycja min-gap | **90%** |
| Złożenie QO | pozostałe przypadki | **15%** |
| Match offer sheet | zawodnik w top-11 OVR i cap pozwala | **85%** |
| Match offer sheet | zawodnik depth (12–18 OVR) | **45%** |
| Match offer sheet | pozycja nadmiarowa | **5%** |
| Match offer sheet | koszt > 1,4 × `assetValue` | **0%** |

Okno na match: 3h / do końca dnia (phase I), 3 dni (phase II) — `contracts.md`.

### 8.5 Staff

6 slotów, cap **15M** (`salary_cap.md`, `staff.md`).

Priorytet zależny od statusu:

| teamStatus | Kolejność obsadzania |
| ---------- | -------------------- |
| `rebuild` | Development Coach → Scout → Head Coach → Doctor → Physio → CFO |
| `retool` | Development Coach → Head Coach → Scout → Doctor → Physio → CFO |
| `pretender` | Head Coach → Doctor → Development Coach → Physio → Scout → CFO |
| `contender` | Head Coach → Doctor → Physio → CFO → Development Coach → Scout |
| `elite` | Head Coach → Doctor → Physio → CFO → Development Coach → Scout |

| Parametr | Wartość |
| -------- | ------: |
| Docelowe wykorzystanie staff cap | **90–100%** (13,5–15,0M) |
| Budżet na Head Coach | do **5,0M** (max) |
| Budżet na role 2–3 priorytetu | 2,0–3,0M każda |
| Budżet na role 4–6 | 0,5–2,0M każda |
| Docelowy `staffOfferScore` | **72** |
| Maksymalny `staffOfferScore` | **88** |
| P(pozostawienia slotu pustego) | **0%**, chyba że cap nie pozwala |
| Przedłużenie: `roleStarsAvg ≥ 2,5` i wiek ≤ 57 | **85%** |
| Przedłużenie: `roleStarsAvg < 1,5` | **20%** (AI szuka lepszego na rynku) |
| Wiek 60 | kontrakt maks. 1 rok (`salary_cap.md`) |

Ponieważ puste slot = kara (`staff.md`), AI zawsze woli słaby sztab niż brak sztabu. Przy 15M na 6 slotów i max 5M za HC realny sztab AI to ~1 mocny HC + 5 średnich — dokładnie ten sam kompromis, który ma gracz.

---

## 9. Zarządzanie rosterem

### 9.1 Legalność rosteru

**Reguła twarda: AI nigdy nie dopuszcza do walkoweru.**

| Sytuacja | Reakcja AI |
| -------- | ---------- |
| Roster < 20 po emeryturach (śr tyg. 44) | plan uzupełnienia; podpisy w FA / draft / niedraftowani |
| Roster < 20 na 2 tygodnie przed tyg. 1 | codzienne oferty FA na `minPlayerSalary`, `offerScore` 90 |
| Roster < 20 w trakcie sezonu | natychmiastowa oferta FA, priorytet nad wszystkim |
| Roster = 30 i potrzeba podpisu | **wymiana** zwalniająca miejsce (§9.3) albo rezygnacja z podpisu — zwolnienie nie istnieje |
| < 11 zdolnych do gry | awaryjny podpis FA w ciągu 1 dnia (wymaga miejsca w rosterze) |

Kontrola przed każdym dniem meczowym. Gwarancja: **0 walkowerów spowodowanych przez AI**.

### 9.2 Reakcja na kontuzje

| Warunek | Reakcja | P |
| ------- | ------- | -: |
| Kontuzja Major zawodnika z XI, brak zmiennika w zasięgu 6 OVR | poszukiwanie wymiany / FA | **70%** |
| Kontuzja Major bramkarza i został 1 GK | podpis FA bramkarza | **85%** |
| Kontuzja Minor | brak reakcji rynkowej, rotacja składu | — |
| Zdolnych do gry ≤ 13 | podpis FA | **90%** |

### 9.3 Zdejmowanie niekorzystnych kontraktów

**Zwolnienia nie istnieją** (`salary_cap.md`). Jedyną drogą pozbycia się kontraktu przed wygaśnięciem jest **wymiana**, a to wymaga dołożenia wartości jako zachęty dla partnera.

#### Identyfikacja kontraktu-kotwicy

```text
contractDrag = (salary − estimatedSalary) / 1 000 000 × yearsRemaining
```

`estimatedSalary` wg wzoru z `player_management.md` (komponent kontraktowy `pointValue`).

| `contractDrag` | Klasyfikacja | Postawa AI |
| -------------: | ------------ | ---------- |
| < 10 | akceptowalny | brak działania |
| 10–29 | uciążliwy | oferuje zdjęcie przy okazji innych wymian |
| 30–59 | kotwica | aktywnie szuka partnera, dokłada pick R3 |
| ≥ 60 | toksyczny | dokłada pick R2, przy `elite`/`contender` nawet R1 |

#### Cena zdjęcia kontraktu

AI godzi się na **ujemny** `surplusPct`, jeśli transakcja zdejmuje `contractDrag`:

| `contractDrag` | Akceptowalny `surplusPct` | Dokładany asset |
| -------------: | ------------------------: | --------------- |
| 10–29 | do **−10%** | brak lub pick R3 w odległym roczniku |
| 30–59 | do **−25%** | pick R3, ewentualnie R2 |
| ≥ 60 | do **−40%** | pick R2; R1 tylko przy `elite`/`contender` i tylko z rocznika ≥ +4 lata |

Hard limit: AI **nigdy** nie oddaje picka R1 z najbliższych 3 roczników wyłącznie za zdjęcie kontraktu.

#### Rola nabywcy

Drużyny `rebuild` i `retool` z dużym cap space **kupują** kontrakty-kotwice, bo dostają za nie picki:

| Warunek | P(AI przyjmuje kontrakt-kotwicę / tydzień) |
| ------- | -----------------------------------------: |
| `rebuild`, cap space > 60M, dokładany pick R1 | **55%** |
| `rebuild`, cap space > 40M, dokładany pick R2 | **35%** |
| `retool`, cap space > 40M, dokładany pick R2 | **25%** |
| `pretender`+ lub cap space < 30M | **0%** |

Ten mechanizm zastępuje zwolnienia jako zawór bezpieczeństwa rynku. Bez niego przepłacone kontrakty krążyłyby po lidze bez możliwości rozładowania.

#### Zwolnienie miejsca w rosterze przy 30 zawodnikach

| Warunek | Reakcja | P |
| ------- | ------- | -: |
| Roster = 30, luka krytyczna, jest zbywalny nadmiarowy zawodnik | wymiana 2-za-1 (oddaje 2, bierze 1) | **50%** |
| Roster = 30, luka krytyczna, brak partnera | rezygnacja z podpisu, gra dostępnym składem | **100%** |
| Roster = 30 przed draftem, posiadane picki | **nie podpisuje** draftowanych, trzyma prawa jako asset (`contracts.md` §9) | **100%** |

AI nie blokuje sobie draftu przez pełny roster — trzymanie praw do wybranego zawodnika jest legalne i darmowe.

---

## 10. Eventy zespołowe

AI rozwiązuje eventy z `team_management.md` automatycznie w dniu ich wystąpienia.

| Event | Decyzja AI | P |
| ----- | ---------- | -: |
| **Prośba o więcej minut** — zawodnik w top-14 OVR | Accept | **75%** |
| **Prośba o więcej minut** — zawodnik poza top-14 | Accept | **35%** |
| **Prośba o transfer I** — `assetValue > 0`, w oknie wymian | Accept | **60%** |
| **Prośba o transfer I** — pozostałe | Decline | **70%** |
| **Prośba o transfer II** | Accept | **70%** |
| **Konflikt w szatni** | Interwencja | **60%** |
| **Publiczna krytyka** | Kara dyscyplinarna 45% / Publiczna odpowiedź 35% / Brak reakcji 20% | — |
| **Lider szatni** / **Deklaracja braku przedłużenia** | automatyczne, brak decyzji | — |

**Dotrzymywanie obietnic:** po Accept na „Prośbę o więcej minut" AI faktycznie podnosi `playerMatchScore` tego zawodnika o **+8%** przy wyborze XI na kolejne 4 tygodnie. Realizuje obietnicę w **~80%** przypadków — reszta skutkuje karą atmosfery tak samo jak u gracza.

Po Accept na prośbę o transfer: `tradeAppetite` dla zawodnika **×3** na 4 tygodnie, gotowość zejścia z `surplusPct` do **−8%**.

Eventy indywidualne zawodników (`player_management.md`) decyzyjne dla AI:

| Event | Decyzja AI | P |
| ----- | ---------- | -: |
| Plateau rozwojowe | Zmiana programu treningowego | **70%** |
| Upadek formy | Rozmowa motywująca | **65%** |
| Komplikacje po kontuzji | Ostrożny powrót | **75%** |
| Spadek motywacji (weteran) | Rola mentora, jeśli `determination ≥ 6` | **80%** |
| Zaangażowanie w trening | Zezwolenie | **60%** (spada do 30% w playoff) |
| Problemy osobiste | Wsparcie klubu | **85%** |

---

## 11. Interakcja z graczem — podsumowanie

Zebrane w jednym miejscu, bo to najbardziej odczuwalna warstwa.

| Kanał | Zachowanie AI | Wolumen / P |
| ----- | ------------- | ----------- |
| **Oferty wymian do gracza** | Startowo +10% na swoją korzyść, schodzi do +2% | 12–20 / sezon |
| **Ocena ofert gracza** | Progi z §5.2, bez biasu | Accept przy fair value ≈ 70% |
| **Kontroferty** | Do 3 rund, potem hard reject | — |
| **Blokada po hard reject** | 30 dni | — |
| **Konkurencja w FA** | Podnosi ofertę o +6 offerScore | 55% gdy gracz też licytuje |
| **Konkurencja w drafcie** | Wybiera wg własnego boardu, bez podglądania gracza | — |
| **Mecze bezpośrednie** | Kontr-formacja po 2 meczach | 65% |
| **Trade-up w drafcie** | Może zaproponować graczowi | 8% / drużyna / draft |
| **RFA match** | Może przebić offer sheet gracza | 85% dla top-11 |

Czego AI **nie robi** w V1:
- nie zabiera prospektów z watchlisty gracza „na złość"
- nie odrzuca fair trade tylko dlatego, że partnerem jest gracz
- nie licytuje FA, którego nie potrzebuje, żeby wypchnąć gracza z rynku
- nie zmienia progów w zależności od pozycji gracza w tabeli

---

## 12. Tabela parametrów

Wszystkie do `/balance/ai_balance.dart`.

| Parametr | Wartość | Sekcja |
| -------- | ------: | ------ |
| `TEAM_POWER_SQUAD_SIZE` | 15 | `team_management.md` |
| `STATUS_MAX_TIER_CHANGE` | 1 | `team_management.md` |
| `ROSTER_TARGET_TOTAL` | 25 | §2.2 |
| `MIN_GAP_THRESHOLD` | 40 | §2.2 |
| `EVALUATION_NOISE_SD` | 4,0 pp | §2.5 |
| `PICK_FUTURE_DISCOUNT` | 0,90 / rok | §2.4 |
| `APRON_PENALTY_PRETENDER` | 40 | §3.1 |
| `APRON_PENALTY_CONTENDER` | 25 | §3.1 |
| `APRON_PENALTY_ELITE` | 15 | §3.1 |
| `P_SECOND_APRON_ENTRY` | 20% | §3.1 |
| `P_COUNTER_FORMATION` | 65% | §4.3 |
| `P_TACTICAL_MATCHUP_ADJUST` | 70% | §4.4 |
| `P_ROLE_OVERRIDE` | 45% | §4.5 |
| `TRADE_ACCEPT_HIGH` | +12% | §5.2 |
| `TRADE_ACCEPT_LOW` | +4% | §5.2 |
| `TRADE_HARD_REJECT` | −30% | §5.2 |
| `TRADE_NEED_SHIFT` | −8 pp | §5.1 |
| `P_OFFER_TO_USER_REGULAR` | 2,0% | §5.4 |
| `P_OFFER_TO_USER_OFFSEASON` | 4,5% | §5.4 |
| `P_OFFER_TO_USER_DEADLINE` | 5,0% | §5.4 |
| `USER_OFFER_COOLDOWN_WEEKS` | 3 | §5.4 |
| `AI_TRADE_PAIRS_PER_WEEK` | 12 | §5.5 |
| `AI_TRADE_MUTUAL_MIN` | +2% | §5.5 |
| `AI_TRADE_SEASON_LIMIT` | 6 | §5.5 |
| `DRAFT_SCORE_NOISE_SD` | 3,5 | §6.1 |
| `P_DRAFT_TRADE_UP` | 8% | §6.3 |
| `SCOUT_COVERAGE_USAGE` | 100% | §7.1 |
| `EXT_TARGET_OFFER_SCORE` | 72 | §8.1 |
| `EXT_MAX_OFFER_SCORE` | 85 | §8.1 |
| `FA_MAX_SALARY_MULT` | 1,35 | §8.2 |
| `FA_COMPETE_BUMP` | +6 | §8.2 |
| `P_FA_COMPETE` | 55% | §8.2 |
| `STAFF_CAP_USAGE_TARGET` | 90–100% | §8.5 |
| `P_MATCH_OFFER_SHEET_TOP11` | 85% | §8.4 |
| `CONTRACT_DRAG_ANCHOR` | 30 | §9.3 |
| `CONTRACT_DRAG_TOXIC` | 60 | §9.3 |
| `DUMP_MAX_NEGATIVE_SURPLUS` | −40% | §9.3 |
| `P_REBUILD_ABSORBS_CONTRACT` | 55% | §9.3 |
| `NTC_MIN_CONSENT_TO_PURSUE` | 35% | §5.6 |
| `SUPERTEAM_BRAKE_THRESHOLD` | +12 `teamPower` | §5.6 |

---

## 13. Kryteria akceptacji

Symulacja **10 sezonów** ligi bez ingerencji gracza musi spełniać:

| Metryka | Przedział docelowy |
| ------- | ------------------ |
| Różnych mistrzów w 10 sezonach | ≥ **6** |
| Najdłuższa seria playoff jednej drużyny | ≤ **8** sezonów |
| Walkowery spowodowane przez AI | **0** |
| Drużyny z legalnym rosterem (20–30) w tyg. 1 | **100%** |
| Wymiany AI↔AI na sezon | **25–45** |
| Oferty AI → gracz na sezon | **12–20** |
| UFA podpisani do tyg. 1 | ≥ **85%** |
| Obsadzone slot sztabu w lidze | ≥ **92%** |
| Średni payroll AI | **88–108%** capu |
| Drużyny powyżej 2nd apron jednocześnie | ≤ **3** |
| Drużyny bez picka R1 w 2 kolejnych latach | **0** (Stepien) |
| Korelacja `expectedRank` ↔ końcowa pozycja w tabeli | **0,55–0,75** |
| Drużyny, które przeszły rebuild → contender w ≤ 4 sezony | **2–6** |
| Mediana wieku rosteru w lidze | **25–28** |
| Kontrakty z `contractDrag ≥ 60` istniejące dłużej niż 2 sezony | ≤ **2** w lidze |
| Wymiany typu „zdjęcie kontraktu" na sezon | **3–10** |
| Odmowy NTC na sezon | **0–4** |

Poza tymi przedziałami tuningowi podlegają w kolejności: `EVALUATION_NOISE_SD`, progi z §5.2, `statusAgeMult`, wolumeny z §5.4–5.5.

---