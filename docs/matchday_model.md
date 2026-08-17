# Model meczowy

Dokument opisuje pełny model symulacji meczu: przebieg minuta-po-minucie, rozstrzyganie sytuacji na podstawie atrybutów zawodników, wpływ taktyki, formy, warunków pozaboiskowych i losowości, a także UX ekranu meczu (pauza, zmiany, symulacja do wyniku).

---

## 1. Idea i zakres

Mecz jest **symulacją liczbową z lekką oprawą tekstową** — bez animacji boiska, zgodnie z `zalozenia_projektowe.md`. Wzorem UX jest tryb kariery z FIFA 15.

| Założenie | Opis |
| --------- | ---- |
| Rozdzielczość czasowa | Zdarzenia rozstrzygane **co minutę** (1–90 + doliczony czas) |
| Ekran meczu | Dwa składy po bokach, wynik i zegar u góry, **feed najważniejszych zdarzeń** w centralnym okienku |
| Kontrola gracza | Play / Pauza, prędkość ×1 / ×2 / ×4, **Symuluj do końca**, panel zmian, panel taktyki |
| Główny wyznacznik wyniku | **Atrybuty zawodników** dopasowane do konkretnej sytuacji boiskowej |
| Modyfikatory | Taktyka (`tactics.md`), zgranie i atmosfera (`team_management.md`), cohesion (`squad_management.md`), sztab (`staff.md`), forma i stamina (`player_management.md`) |
| Losowość | Każdy pojedynek ma składnik losowy — identyczne składy nie dają identycznych wyników |
| Kontekst pozaboiskowy | Pogoda, temperatura, derby, gospodarz, stawka meczu, sędzia |

### Zasada nadrzędna: atrybuty > taktyka

Taktyka **modeluje przewagi kontekstowe**, ale nie zastępuje jakości zawodników. Docelowy podział wpływu na wynik:

| Warstwa | Udział w sile drużyny (orientacyjnie) |
| ------- | -----------------------------------: |
| Efektywne atrybuty zawodników (z formą i staminą) | **~70%** |
| Taktyka: formacja, ustawienia, role, matchupy | ~15% |
| Zgranie, cohesion, atmosfera, sztab | ~10% |
| Kontekst pozaboiskowy (pogoda, derby, gospodarz) | ~5% |

Losowość działa **ponad** tymi warstwami i odpowiada za rozstrzęp wyników (§14).

---

## 2. Cykl życia meczu

```text
PRE-MATCH
  → walidacja rosteru (walkower?)                        [§3.1]
  → budowa MatchContext (pogoda, derby, stawka, sędzia)  [§3.2]
  → snapshot składów + ustawień taktycznych              [§3.3]
  → obliczenie TeamShape (def'/mid'/atk')                [§4]
  → obliczenie UnitRatings z atrybutów zawodników        [§6.2]
  → seed RNG meczu                                       [§14.1]
  → wiadomość matchPreview                               (messages.md)

KICK-OFF
  ┌── PĘTLA MINUTOWA (m = 1 … 45)                        [§6]
  │     1. tick staminy
  │     2. przeliczenie effAttr on-pitch
  │     3. roll posiadania
  │     4. roll liczby sekwencji w tej minucie
  │     5. dla każdej sekwencji: typ → łańcuch pojedynków → wynik
  │     6. rozstrzygnięcie strzału (jeśli powstał)
  │     7. rolle wtórne: faul / kartka / kontuzja
  │     8. aktualizacja momentum i game state
  │     9. emisja zdarzeń do feedu
  └── HALF-TIME                                          [§11.3]
        → zmiany, korekta taktyki (bez kary cohesion)
  ┌── PĘTLA MINUTOWA (m = 46 … 90)
  └── DOLICZONY CZAS                                     [§6.6]

FULL-TIME
  → matchRating każdego zawodnika                        [§15]
  → efekty pomeczowe                                     [§16]
  → zapis do seasonStats, tabeli, historii
  → wiadomość matchResult + ewentualne injury/card       (messages.md)
```

Symulacja natychmiastowa wykonuje **identyczną pętlę**, tylko bez ingerencji użytkownika (nie wykonuje zmian, chyba że wymuszone przez kontuzję) i z natychmiastowym przedstawienie wyniku i wszystkich kluczowych wydarzeń.

---

## 3. Faza pre-match

### 3.1 Walidacja i walkower

Sprawdzane w kolejności, przed jakąkolwiek symulacją (`squad_management.md`):

| Warunek | Skutek |
| ------- | ------ |
| Rozmiar rosteru < 20 lub > 30 | Walkower **0–3** dla rywala, wiadomość `walkover` (urgent) |
| Obie drużyny z nielegalnym rosterem | Wynik `dsq`, brak punktów dla obu |
| Mniej niż 11 zdolnych do gry | Walkower **0–3** dla rywala |
| Brak `Position.gk` w XI | Mecz **rozgrywany**, ale z karą bramkarską (§9.4) — typowy wynik ~0–5 |
| Ławka < 7 (kontuzje/zawieszenia) | Mecz rozgrywany, mniej zmienników; komunikat informacyjny |

Walkower nie generuje zdarzeń boiskowych, staminy ani statystyk indywidualnych. Skutkuje **−15 atmosfery** (`team_management.md`).

### 3.2 MatchContext

Kontekst wyznaczany raz przed meczem, niezmienny przez całe spotkanie.

| Pole | Typ / zakres | Źródło |
| ---- | ------------ | ------ |
| `homeTeamId` / `awayTeamId` | id | harmonogram |
| `weather` | enum (§13.1) | losowanie zależne od tygodnia sezonu |
| `temperatureC` | −5 … 38 | losowanie zależne od tygodnia sezonu |
| `isDerby` | bool | tabela rywalizacji + ta sama konferencja |
| `stake` | `regular`, `playIn`, `playoff`, `playoffElimination`, `leagueFinal` | kalendarz |
| `refereeStrictness` | 0,80 … 1,20 | losowanie na mecz |
| `crowdIntensity` | 0 … 100 | forma gospodarza + stawka + derby |
| `homeMatchInWeek` / `awayMatchInWeek` | 1 lub 2 | kalendarz |
| `seed` | int | §14.1 |

### 3.3 Snapshot składów

Zamrażany jest stan: XI, ławka, pozycje, role, ustawienia taktyczne, atrybuty bazowe, stamina, forma, zgranie, atmosfera, cohesion, sztab. Zmiany w rosterze poza meczem nie wpływają na trwającą symulację.

---

## 4. TeamShape — warstwa taktyczna

`TeamShape` to trójka `def'` / `mid'` / `atk'` obliczona według `tactics.md`:

```text
def' = formation.def + tacticsΔ.def + rolesΔ.def + Σ ΔD(matchupy) + headCoach.tacticsBoost
mid' = formation.mid + tacticsΔ.mid + rolesΔ.mid + Σ ΔM(matchupy) + headCoach.tacticsBoost
atk' = formation.atk + tacticsΔ.atk + rolesΔ.atk + Σ ΔA(matchupy) + headCoach.tacticsBoost
```

Boost Head Coacha (`staff.md`, Tactics ★) dodawany do **wszystkich trzech** filarów.

TeamShape nie jest bezpośrednio siłą drużyny — jest **mnożnikiem taktycznym** nakładanym na siłę z atrybutów:

```text
tacticalMult(x) = 1 + (shape'(x) − SHAPE_BASELINE) × SHAPE_WEIGHT
```

| Stała | Wartość | Efekt |
| ----- | ------: | ----- |
| `SHAPE_BASELINE` | 55 | punkt neutralny |
| `SHAPE_WEIGHT` | 0,0025 | shape 75 → ×1,05; shape 35 → ×0,95 |

Realny zakres `shape'` (~30–90) daje **×0,94 … ×1,09**. Celowo wąskie okno — taktyka przeważa wyrównane mecze, ale nie odwraca różnicy klas.

---

## 5. Efektywne atrybuty zawodnika

### 5.1 Pipeline

Dla każdego zawodnika na boisku i każdego atrybutu, **przeliczane co minutę**:

```text
effAttr(p, a, m) = clamp(
    base(p, a)
  × positionMult(p)
  × roleFitMult(p)
  × chemistryMult(team)
  × cohesionMult(team)
  × atmosphereMult(team)
  × formMult(p)
  × staminaMult(p, m)
  × contextMult(p, ctx)
  × leaderMult(team)
, 1, 120)
```

| Mnożnik | Zakres | Źródło |
| ------- | ------ | ------ |
| `positionMult` | 0,90 (obca pozycja) / 1,00 | `squad_management.md` |
| `roleFitMult` | 1,00 / **1,03** (optymalna rola) | `squad_management.md` |
| `chemistryMult` | 0,95 … 1,05 | `team_management.md` |
| `cohesionMult` | 1,01 … 1,05 × HC Motivation | `squad_management.md`, `staff.md` |
| `atmosphereMult` | 0,95 … 1,04 | `team_management.md` |
| `formMult` | 0,90 … 1,12 | `player_management.md` |
| `staminaMult` | 0,50 … 1,00 (`performanceMult`) | `player_management.md` |
| `contextMult` | 0,92 … 1,06 | §13 |
| `leaderMult` | 1,00 / **1,02** | §5.3 |

### 5.2 Dlaczego forma i stamina są kluczowe

`formMult` (0,90–1,12) i `staminaMult` (0,50–1,00) mają **najszerszy zakres** ze wszystkich mnożników. Zawodnik 85 OVR w formie 2 i przy staminie 30 działa jak ~59 OVR. To wymusza rotację i czyni zarządzanie formą realną decyzją menedżerską przy 2 meczach/tydzień (`game_calendar.md`).

### 5.3 Efekty osobowości w meczu

Domknięcie odwołań z `player_management.md`:

| Osobowość | Efekt meczowy |
| --------- | ------------- |
| `leader` | Obecność w XI: `leaderMult` **×1,02** dla całej drużyny. Przy przegrywaniu od 60' momentum drift **+8** na korzyść drużyny (§12) |
| `temperamental` | `cardProneMult` **×1,35** (§8), po stracie gola `formSwing` ×1,5 przy aktualizacji pomeczowej |
| `professional` | `injuryMult` **×0,80** (§10) |
| `ambitious` | +0,03 do `clutchFactor` w sytuacjach decydujących (§7.5) |
| `loyal` | Przeciwne momentum działa na tego zawodnika w 80% |
| `balanced` | Brak modyfikatora |

`leaderMult` nie kumuluje się — liczy się obecność co najmniej jednego lidera.

---

## 6. Pętla minutowa

### 6.1 Tick staminy

Zużycie per minuta zgodnie z tabelą pozycji z `player_management.md`, z mnożnikami tempa, pressingu, pogody i derby. Zmiennik startuje ze swoją bieżącą staminą.

### 6.2 UnitRatings

Z efektywnych atrybutów budowane są trzy oceny jednostek. Przypisanie na podstawie pozycji w formacji (`tactics.md`, kształt D–M–A).

| Jednostka | Skład | Wagi atrybutów |
| --------- | ----- | -------------- |
| `defRating` | linia obrony + CDM | defending 0,45 · physicality 0,25 · pace 0,20 · passing 0,10 |
| `midRating` | CDM/CM/CAM + skrzydłowi | passing 0,35 · dribbling 0,25 · defending 0,20 · physicality 0,20 |
| `atkRating` | ST + skrzydłowi + CAM | shooting 0,35 · pace 0,25 · dribbling 0,25 · passing 0,15 |

```text
unitRating(x) = weightedMean(effAttr zawodników jednostki) × tacticalMult(x)
```

Średnia **ważona pozycyjnie** — kluczowe pozycje waga 1,0, wspierające 0,5.

### 6.3 Roll posiadania

```text
P(posiadanie A) = contest(midRating_A, midRating_B)
```

`contest` z §7.1. Wynik przekłada się na statystykę posiadania (średnia z minut).

Modyfikatory: `Tempo.slow` +0,03, `Tempo.fast` −0,03, `PressingIntensity.gegenpressing` +0,04.

### 6.4 Liczba sekwencji w minucie

```text
λ = SEQ_BASE × tempoMult × pressingMult × momentumMult × stakeMult
liczbaSekwencji ~ Poisson(λ), clamp 0…3
```

| Stała | Wartość |
| ----- | ------: |
| `SEQ_BASE` | 1,15 |
| `tempoMult` | slow 0,88 · balanced 1,00 · fast 1,18 |
| `pressingMult` | low 0,94 · medium 1,00 · high 1,08 · gegenpressing 1,14 |

Daje ~100–110 sekwencji na mecz, ~52 na drużynę.

### 6.5 Lejek konwersji

| Etap | Prawdopodobieństwo bazowe | Rezultat na mecz/drużynę |
| ---- | ------------------------: | -----------------------: |
| Sekwencja → sytuacja strzelecka | 22% | ~11,4 strzałów |
| Strzał → gol | 11,5% | ~1,3 gola |

Cel kalibracyjny: **~2,6 gola na mecz**, ~52% zwycięstw gospodarza, ~24% remisów.

### 6.6 Doliczony czas

```text
stoppage = 1 + round(0,5 × (gole + kartki + kontuzje + zmiany) × RNG(0,7…1,3))
```

Clamp 1–8 minut. Pierwsza połowa: `floor(stoppage / 3)`.

---

## 7. Rozstrzyganie sytuacji

### 7.1 Rdzeń: pojedynek

Wszystkie interakcje sprowadzają się do pojedynku dwóch ocen złożonych z atrybutów:

```text
R_atk = Σ (waga_i × effAttr(atakujący, atrybut_i))
R_def = Σ (waga_j × effAttr(broniący, atrybut_j))

R'_atk = R_atk + N(0, DUEL_SIGMA)
R'_def = R_def + N(0, DUEL_SIGMA)

P(atakujący wygrywa) = 1 / (1 + 10^((R'_def − R'_atk) / DUEL_DISPERSION))
```

| Stała | Wartość | Znaczenie |
| ----- | ------: | --------- |
| `DUEL_DISPERSION` | 35 | +10 przewagi → ~66%; +25 → ~84% |
| `DUEL_SIGMA` | 6,0 | szum gaussowski na pojedynek — źródło upsetów |

Szum jest **niezależny dla każdego pojedynku**, więc słabsza drużyna wygrywa część starć nawet przy dużej różnicy klas. Główny mechanizm niedeterministyczności.

### 7.2 Wybór broniącego

Broniący losowany z jednostki defensywnej z wagami zależnymi od typu sekwencji (np. `wingPlay` po lewej → LB waga 3,0, LCB 1,5, CDM 0,8). Zapewnia realną eksploatację słabych punktów składu.

### 7.3 Typy sekwencji

| Typ | Waga bazowa | Warunek zwiększenia wagi |
| --- | ----------: | ------------------------ |
| `centralBuildUp` | 22 | `AttackWidth.narrow`, wysoki `midRating` |
| `wingPlay` | 20 | `AttackWidth.wide`, skrzydłowi z wysokim pace |
| `crossFromWide` | 12 | `AttackWidth.wide` + wysoki `heightCm` napastnika |
| `throughBall` | 11 | wysoki passing kreatora + wysoki pace napastnika |
| `individualDribble` | 10 | wysoki dribbling w ataku |
| `longBall` | 8 | `Tempo.fast`, `deep` linia, wysoki `heightCm` ST, `wind`/`heavyRain` |
| `counterAttack` | 9 | po odbiorze piłki, `Tempo.fast`, wysoki pace |
| `setPiece` | 8 | wynik rolla faulu/rzutu rożnego (§7.6) |

### 7.4 Mapowanie atrybutów na sytuacje

**Serce modelu.** Każdy typ sekwencji to łańcuch 2–3 pojedynków z własnymi wagami.

#### `centralBuildUp`

| Pojedynek | Atakujący | Broniący |
| --------- | --------- | -------- |
| 1. Progresja | passing 0,55 · dribbling 0,30 · physicality 0,15 (CM/CAM) | defending 0,55 · physicality 0,30 · pace 0,15 (CDM/CM) |
| 2. Ostatnie podanie | passing 0,70 · dribbling 0,30 (CAM) | defending 0,60 · pace 0,40 (CB) |

#### `wingPlay`

| Pojedynek | Atakujący | Broniący |
| --------- | --------- | -------- |
| 1. Pojedynek 1v1 | pace 0,40 · dribbling 0,45 · physicality 0,15 (W/FB) | defending 0,45 · pace 0,40 · physicality 0,15 (FB) |
| 2. Wejście w pole | passing 0,50 · dribbling 0,50 | defending 0,70 · physicality 0,30 (CB) |

#### `crossFromWide`

| Pojedynek | Atakujący | Broniący |
| --------- | --------- | -------- |
| 1. Dośrodkowanie | passing 0,80 · pace 0,20 (skrzydłowy) | defending 0,60 · pace 0,40 (FB) |
| 2. Gra w powietrzu | physicality 0,55 · `aerialFactor` 0,15 · shooting 0,30 (ST) | defending 0,50 · physicality 0,35 · `aerialFactor` 0,15 (CB) |

```text
aerialFactor(p) = clamp(60 + (heightCm − 180) × 1,2, 35, 85)
```

| Wzrost | `aerialFactor` |
| -----: | -------------: |
| 168 cm | 45,6 |
| 175 cm | 54,0 |
| 180 cm | 60,0 |
| 190 cm | 72,0 |
| 200 cm | 84,0 |

Waga **0,15** celowo niska — wzrost przeważa wyrównane starcia powietrzne (~54,5% przy +18 cm różnicy), ale nie dominuje nad atrybutami fizycznymi i defensywnymi.

#### `throughBall`

| Pojedynek | Atakujący | Broniący |
| --------- | --------- | -------- |
| 1. Podanie | passing 0,85 · dribbling 0,15 (kreator) | defending 0,50 · physicality 0,50 (CDM) |
| 2. Bieg za linię | pace 0,70 · dribbling 0,30 (ST/W) | pace 0,55 · defending 0,45 (CB) — **+0,10 do pace przy `DefensiveLine.high`** |

#### `individualDribble`

| Pojedynek | Atakujący | Broniący |
| --------- | --------- | -------- |
| 1. Drybling | dribbling 0,60 · pace 0,25 · physicality 0,15 | defending 0,55 · pace 0,25 · physicality 0,20 |
| 2. Wyjście na pozycję | dribbling 0,50 · shooting 0,50 | defending 0,80 · physicality 0,20 |

#### `longBall`

| Pojedynek | Atakujący | Broniący |
| --------- | --------- | -------- |
| 1. Podanie długie | passing 0,70 · physicality 0,30 (CB/CDM, GK kicking) | próg trudności, nie pojedynek |
| 2. Zgranie | physicality 0,50 · `aerialFactor` 0,15 · dribbling 0,35 (ST) | defending 0,45 · physicality 0,40 · `aerialFactor` 0,15 (CB) |

#### `counterAttack`

Wyzwalany po przegranym przez rywala pojedynku obronnym. Jakość sytuacji **×1,35** (obrona rozciągnięta).

| Pojedynek | Atakujący | Broniący |
| --------- | --------- | -------- |
| 1. Wyprowadzenie | pace 0,50 · dribbling 0,30 · passing 0,20 | pace 0,60 · defending 0,40 |
| 2. Finalizacja | shooting 0,55 · dribbling 0,25 · pace 0,20 | defending 0,65 · pace 0,35 |

`DefensiveLine.high` rywala: dodatkowo ×1,15 do jakości kontry. `deep`: ×0,85.

### 7.5 Clutch factor

W sytuacjach decydujących (rzut karny, minuty 85+, playoff eliminacyjny) doliczany jest wpływ ukrytej `determination` (`player_management.md`):

```text
clutchBonus = (determination − 5,5) × CLUTCH_WEIGHT × stakePressure
CLUTCH_WEIGHT = 1,2
stakePressure: regular 0,5 · playIn 1,0 · playoff 1,0 · playoffElimination 1,4 · leagueFinal 1,6
```

Zakres **−7,6 … +7,6** do oceny w pojedynku. `ambitious` dodaje +0,03 mnożnika.

Jedyne miejsce, gdzie `determination` wpływa na mecz — poza rozwojem zawodnika.

### 7.6 Stałe fragmenty gry

| Typ | Prawdopodobieństwo powstania | Bazowe xG |
| --- | ---------------------------- | --------: |
| Rzut rożny | ~35% zablokowanych strzałów + 10% nieudanych dośrodkowań | 0,035 |
| Wolny bezpośredni | ~18% fauli w strefie 20–30 m | 0,07 |
| Rzut karny | ~4% fauli w polu karnym | 0,76 |

Ustawienia SFG (`cornersAttack`, `cornersDefense`, `freeKicks`, `penalties`, domyślnie 50) skalują te wartości:

```text
sfgMult = 1 + (setting − 50) / 250     // ×0,80 … ×1,20
```

#### Wpływ wzrostu na SFG (aerialEdge)

Rożne i wolne to sytuacje zbiorowe — `heightCm` działa przez rating jednostki, nie przez pojedynczy pojedynek:

```text
teamAerialAtk = mean(aerialFactor 4 najwyższych zawodników w XI atakującego)
teamAerialDef = mean(aerialFactor GK + 3 najwyższych obrońców w XI broniącego)
aerialEdge    = clamp(teamAerialAtk − teamAerialDef, −25, +25)
```

| Typ SFG | Modyfikator xG | Zakres |
| ------- | -------------- | ------ |
| Rzut rożny | `cornerXgMult = 1 + aerialEdge × 0,006` | ×0,85 … ×1,15 |
| Wolny bezpośredni | `freeKickXgMult = 1 + aerialEdge × 0,003` | ×0,925 … ×1,075 |
| Rzut karny | brak wpływu wzrostu | — |

Symetria: wysoka obrona obniża `aerialEdge` rywala tak samo, jak wysoki atak go podnosi.

Wykonawca: najwyższy `shooting` (wolne, karne) lub `passing` (rożne) w XI. Rzut karny: `shooting 0,60 · clutchBonus` vs GK `diving 0,35 · reflexes 0,35 · positioning 0,30`.

---

## 8. Faule, kartki, zawieszenia

### 8.1 Faul

Rolowany po **każdym przegranym pojedynku obronnym**:

```text
P(faul) = FOUL_BASE × pressingMult × physGapMult × cardProneMult × derbyMult × refereeStrictness
```

| Czynnik | Wartość |
| ------- | ------: |
| `FOUL_BASE` | 0,085 |
| `pressingMult` | low 0,85 · medium 1,00 · high 1,15 · gegenpressing 1,30 |
| `physGapMult` | 1 + (defPhysicality − atkPace) / 300 |
| `cardProneMult` | 1,00 / **1,35** (`temperamental`) |
| `derbyMult` | 1,00 / **1,15** |
| `refereeStrictness` | 0,80 … 1,20 |

Cel: ~11 fauli na drużynę na mecz.

### 8.2 Kartki

| Zdarzenie | Prawdopodobieństwo |
| --------- | -----------------: |
| Żółta z faulu | 13% × `refereeStrictness` × `cardProneMult` |
| Druga żółta → czerwona | automatycznie |
| Czerwona bezpośrednia | 0,7% faulu, ×2 jeśli faul przerywał sytuację 1-na-1 |

Cel: ~1,9 żółtej i ~0,06 czerwonej na drużynę na mecz.

### 8.3 Gra w osłabieniu

| Stan | Efekt |
| ---- | ----- |
| 10 zawodników | `atkRating` ×0,86, `defRating` ×0,92, stamina ×1,12 |
| 9 zawodników | `atkRating` ×0,70, `defRating` ×0,80, stamina ×1,20 |

Czerwona kartka wymusza rekonfigurację XI (usuwany zawodnik z najsłabszej jednostki względem stanu meczu; przy braku GK — §9.4).

### 8.4 Zawieszenia

| Warunek | Kara |
| ------- | ---- |
| 5 żółtych w sezonie regularnym | 1 mecz, licznik resetowany |
| Czerwona za drugą żółtą | 1 mecz |
| Czerwona bezpośrednia | 1–3 mecze (ważone ciężkością) |
| Playoff | osobny licznik żółtych, próg **3** |

Zawieszony nie może wejść do protokołu (`squad_management.md`).

---

## 9. Model bramkarza

### 9.1 Wagi atrybutów per typ strzału

| Typ strzału | Wagi GK |
| ----------- | ------- |
| Z dystansu (>20 m) | reflexes 0,40 · positioning 0,35 · diving 0,25 |
| Z pola karnego | reflexes 0,35 · diving 0,35 · positioning 0,30 |
| Główka po dośrodkowaniu | positioning 0,40 · handling 0,35 · diving 0,25 |
| 1-na-1 z napastnikiem | positioning 0,35 · speed 0,30 · diving 0,35 |
| Rzut karny | diving 0,35 · reflexes 0,35 · positioning 0,30 |

### 9.2 Rozstrzygnięcie strzału

```text
xG = clamp(baseXg(sekwencja) × chanceQualityMult × shooterFactor, 0,01, 0,95)

shooterFactor = 1 + (effShooting − 70) / 180
gkFactor      = 1 − (gkRating − 70) / 240

P(gol) = clamp(xG × gkFactor, 0,005, 0,97)
```

`chanceQualityMult` z liczby wygranych pojedynków w łańcuchu: 1 → ×0,7, 2 → ×1,0, 3 → ×1,4.

### 9.3 Wynik strzału (gdy nie gol)

| Rezultat | Prawdopodobieństwo | Następstwo |
| -------- | -----------------: | ---------- |
| Obroniony | 42% | 25% szans na dobitkę (nowa sekwencja, xG ×0,6) |
| Niecelny | 33% | koniec sekwencji |
| Zablokowany | 20% | 35% szans na rzut rożny |
| Słupek / poprzeczka | 5% | 30% szans na dobitkę |

Błąd bramkarza: `P = (100 − handling) / 1200 × weatherHandlingMult` — przy `heavyRain`/`snow` istotnie rośnie (§13.1).

### 9.4 Brak bramkarza (kara ~0–5)

```text
gkRating = (physicality × 0,4 + pace × 0,3 + defending × 0,3) × 0,55
```

Dla zawodnika 75 OVR daje ~41 — przy standardowym `gkFactor` przekłada się na ~3–5 straconych bramek. AI **zawsze** unika tej sytuacji (`AI_behaviour.md`).

---

## 10. Kontuzje w meczu

Rolowane per zawodnik na boisku, per minuta:

```text
P(kontuzja) = INJURY_BASE
  × injuryProneMult      // 0,50 … 2,00  (player_management.md)
  × staminaInjuryMult    // 0,90 … 1,67  (player_management.md)
  × physioRehabMult      // 0,87 … 1,05  (staff.md)
  × doctorPreventionMult // 0,87 … 1,05  (staff.md)
  × professionalMult     // 0,80 / 1,00
  × intensityMult        // tempo + pressing
  × weatherMult          // §13.1
  × duelMult             // ×2,5 jeśli brał udział w pojedynku w tej minucie
```

| Stała | Wartość |
| ----- | ------: |
| `INJURY_BASE` | 0,00018 |
| `intensityMult` | fast 1,15 · gegenpressing 1,20 · slow 0,92 · low press 0,92 |

Daje ~0,18 kontuzji na drużynę na mecz (~1 na 5–6 meczów).

Typ losowany z rozkładu z `player_management.md`. Czas trwania × `doctorCareMult`. Kontuzjowany **musi** zostać zmieniony — jeśli nie ma zmian, drużyna gra w osłabieniu (§8.3). Wiadomość `injury` (urgent, jeśli XI).

### 10.1 Implementacja runtime Task 20

`SimulationMatchEngine` wykonuje rolle incydentów po rozstrzygnięciu sekwencji, ale przed zamknięciem minuty. `MatchIncidentResolver` jest bezstanowym współdzielonym miejscem wzorów: nie tworzy własnego `Random`, tylko dostaje callbacki `nextDouble`/`nextInt` z meczowego `MatchRandom`. Dzięki temu kolejność losowań i `traceSignature` pozostają deterministyczne dla tego samego seeda.

Faule są sprawdzane wyłącznie dla przegranych pojedynków obronnych. Udany roll zwiększa bieżący licznik drużyny i dodaje `MatchEventType.foul`; następnie resolver może dodać żółtą kartkę, drugą żółtą z automatyczną czerwoną albo czerwoną bezpośrednią z severity 1–3. `MatchDiscipline` jest scalane po zawodniku, a `SimulationResult.homeStats`/`awayStats` wylicza z tych danych kartki i z runtime’u faule. Trwałe liczniki sezonowe oraz zawieszenia pozostają po stronie istniejącego `DisciplineService` Task 11.

Po czerwonej zawodnik jest usuwany z bieżącego XI, `sentOffPlayerIds`, mapa slotów i ratingi jednostek są odświeżane, a `homeNoGkPenalty`/`awayNoGkPenalty` są wyliczane z aktualnego XI. Mnożniki gry w osłabieniu są stosowane w `UnitRatingCalculator` oraz przy ticku staminy; nie są nakładane drugi raz w mocy drużyny.

Kontuzje są rolowane raz na każdego zawodnika pozostającego na boisku w danej minucie. Udział w którymkolwiek pojedynku tej minuty ustawia `duelMult = 2,5`. Diagnoza zapisuje istniejący model `Injury` w `MatchInjury` i dodaje event minor/major, po czym uruchamia wymuszoną zmianę. Brak dostępnej ławki usuwa zawodnika z XI, zapisuje ID w `unreplacedInjuryIds` i pozostawia drużynę w dynamicznym osłabieniu, również przy utracie GK.

---

## 11. Ingerencje menedżera

### 11.1 Pauza

Gracz może zatrzymać mecz w dowolnej minucie. W pauzie dostępne: panel zmian, panel taktyki, statystyki, oceny, lista zdarzeń.

Automatyczna pauza (konfigurowalna, spójna z `messages.md`):

| Zdarzenie | Domyślnie |
| --------- | --------- |
| Kontuzja własnego zawodnika | pauza |
| Czerwona kartka | pauza |
| Gol (dowolny) | bez pauzy |
| Przerwa | pauza |
| Rzut karny dla nas | pauza |

### 11.2 Zmiany

| Reguła | Wartość |
| ------ | ------: |
| Limit zmian | 5 |
| Okna zmian | 3 (+ przerwa poza limitem) |
| Źródło | wyłącznie bieżąca 7-osobowa ławka (`squad_management.md`) |
| Wymuszona zmiana Major | zużywa limit 5, omija limit zwykłych okien |

Runtime udostępnia `SimulationLiveMatch.applySubstitution` oraz wariant `applySubstitutionResult`. Zmiennik jest pobierany wyłącznie z bieżącej ławki, zachowuje pozycję slotu zawodnika schodzącego i wchodzi z istniejącą wartością `staminaRemaining`. Zawodnik, który opuścił boisko, nie może ponownie wejść w tym samym meczu.

Kilka zmian w tym samym zatrzymaniu zużywa jedno okno. Służy do tego opcjonalny `windowId`; gdy go nie podano, kluczem okna jest bieżąca minuta (`minute:<minute>`). Przerwa nie rejestruje zwykłego okna, ale nadal obowiązuje limit pięciu zawodników. `cohesionMult` i ratingi jednostek są po każdej zaakceptowanej zmianie przeliczane z runtime'owej mapy slotów, więc możliwa jest także obca pozycja naturalna.

Adaptacja do zgrania korzysta z snapshotu `Team.chemistryAppearances`: dla 0 występów kara wynosi `1,0`, maleje liniowo do `0,0` przy 5 występach i jest konfigurowana przez `MatchdayBalance` (`adaptationAppearances`, `adaptationPenaltyAtZero`).

Przy kontuzji Major `applyMajorInjurySubstitution` wymusza zmianę i omija limit zwykłych okien, lecz nie limit pięciu zmian. Gdy bieżąca ławka nie zawiera dostępnego zmiennika, mecz pozostaje bez uzupełnienia, a ID jest przechowywane w runtime jako `homeUnreplacedMajorInjuryIds` lub `awayUnreplacedMajorInjuryIds`.

### 11.3 Przerwa

W runtime przerwa jest reprezentowana przez minutę 45. W przerwie gracz może wykonać zmiany i zmienić ustawienia taktyczne (w tym formację) **bez kary cohesion** i bez zużywania zwykłego okna zmian. Limit pięciu zmian nadal obowiązuje. Zmiana formacji mapuje bieżące XI na sloty `FormationLayout`.

Poza przerwą zmiana formacji jest niedostępna: komenda jest odrzucana i nie zmienia stanu. HC **Motivation ★** (`staff.md`) nadal wpływa na mecz przez `cohesionMult` (§5.1) — nie wymaga osobnej mechaniki przemowy.

### 11.4 Korekta taktyki w trakcie meczu

`SimulationLiveMatch.updateTactics` pozwala zmienić ustawienia; poza przerwą korekta kosztuje bezpośrednio **−2 / 100 (`−0,02`) w `cohesionMultiplier` przez 10 minut**. Timer wygasa, gdy `expiresAtMinute <= state.minute`; kolejna korekta odświeża go i nie kumuluje kilku kar.

Zmiana formacji możliwa jest tylko w przerwie. Stałe `cohesionTacticsPenalty` i `cohesionPenaltyDurationMinutes` znajdują się w `MatchdayBalance`, a stan timera pozostaje runtime-only i nie trafia do modeli zapisu.

### 11.5 AI przeciwnika

AI decyduje w tych samych momentach co gracz — limit zmian, okna i przerwa obowiązują jednakowo. Reguły decyzyjne w `AI_behaviour.md` §4.7.

Skrót kluczowych triggerów (wartości P i detale w `AI_behaviour.md`):

| Trigger | Akcja |
| ------- | ----- |
| Kontuzja | zmiana (100%) |
| Stamina < 45 | zmiana (85–95%) |
| Przegrywa od 60–65' | zmiana ofensywna + korekta taktyki |
| Wygrywa od 75–78' | zmiana defensywna / odciążenie |
| Gra w 10 | rekonfiguracja + `DefensiveLine.deep` |
| Kontr-formacja (≥ 2 mecze z przeciwnikiem) | dobór formacji z dodatnim ΔM/ΔA (65%) |

---

## 12. Momentum i stan meczu

### 12.1 Momentum

`momentum ∈ [−100, +100]`, wartości dodatnie na korzyść gospodarza.

| Zdarzenie | Δ momentum |
| --------- | ---------: |
| Gol | **+25** dla strzelca |
| Niewykorzystana duża sytuacja (xG > 0,4) | +8 dla atakującego |
| Obroniony rzut karny | +18 dla broniącego |
| Czerwona kartka | −20 dla ukaranego |
| Kontuzja kluczowego zawodnika | −8 |
| Co minutę | zanik ×0,96 w stronę 0 |

Efekt: `momentumMult = 1 + momentum / 1500` (×0,933 … ×1,067) na `atkRating` drużyny prowadzącej momentum oraz na `λ`.

### 12.2 Wpływ wyniku na zachowanie

Od 65. minuty rozkład typów sekwencji i `TeamShape` przesuwają się automatycznie:

| Stan | Efekt |
| ---- | ----- |
| Przegrywa 1 golem | `atk'` +6, `def'` −5, `λ` ×1,10 |
| Przegrywa 2+ golami | `atk'` +10, `def'` −9, `λ` ×1,18, `longBall` waga ×1,6 |
| Wygrywa 1 golem | `def'` +5, `atk'` −4, `λ` ×0,94 |
| Wygrywa 2+ golami | `def'` +7, `atk'` −6, `λ` ×0,88 |

Drużyna gracza podlega temu tylko jeśli gracz nie ustawił ręcznie taktyki po 65. minucie.

---

## 13. Warunki pozaboiskowe

### 13.1 Pogoda

Losowana per mecz, rozkład zależny od tygodnia sezonu (sierpień → upały, zima → śnieg).

| Pogoda | Δ passing | Δ pace | GK błąd | Stamina | Kontuzje | xG | Notatka |
| ------ | --------: | -----: | ------: | ------: | -------: | -: | ------- |
| `clear` | ×1,00 | ×1,00 | ×1,00 | ×1,00 | ×1,00 | ×1,00 | neutralna |
| `overcast` | ×1,00 | ×1,00 | ×1,00 | ×0,98 | ×1,00 | ×1,00 | idealne warunki |
| `rain` | ×0,96 | ×0,98 | ×1,25 | ×1,03 | ×1,08 | ×1,02 | śliska piłka |
| `heavyRain` | ×0,90 | ×0,94 | ×1,60 | ×1,08 | ×1,15 | ×1,05 | chaos, więcej błędów |
| `wind` | ×0,93 | ×1,00 | ×1,30 | ×1,02 | ×1,00 | ×0,97 | `longBall` waga ×1,4 |
| `snow` | ×0,88 | ×0,90 | ×1,45 | ×1,10 | ×1,18 | ×0,95 | najniższa jakość gry |
| `heat` | ×0,98 | ×0,96 | ×1,05 | **×1,15** | ×1,10 | ×0,98 | zgodne z `player_management.md` |
| `cold` | ×0,98 | ×0,97 | ×1,08 | ×1,04 | ×1,12 | ×1,00 | sztywność mięśni |

Pogoda działa przez `contextMult` na odpowiednie atrybuty, nie na cały profil zawodnika.

### 13.2 Temperatura

```text
tempStaminaMult = 1 + max(0, temperatureC − 24) × 0,012 + max(0, 4 − temperatureC) × 0,008
```

Przy 34 °C → ×1,12. Przy −4 °C → ×1,06.

### 13.3 Derby

| Efekt | Wartość |
| ----- | ------: |
| Faule i kartki | ×1,15 |
| Zużycie staminy | ×1,05 (zgodne z `player_management.md`) |
| Skala zmian momentum | ×1,25 |
| `crowdIntensity` | +20 |
| `λ` sekwencji | ×1,05 |

### 13.4 Gospodarz i publiczność

```text
crowdIntensity = clamp(45 + formaGospodarza × 0,3 + stakeBonus + derbyBonus, 0, 100)
```

| Efekt | Wartość |
| ----- | ------: |
| `contextMult` gospodarza | 1 + `crowdIntensity` / 2500 (do ×1,04) |
| `contextMult` gościa | 1 − `crowdIntensity` / 4000 (do ×0,975) |
| Bias sędziego (faule przeciw gościom) | ×(1 + `crowdIntensity` / 1500) |
| Startowe momentum | +`crowdIntensity` / 8 |

### 13.5 Stawka meczu

| `stake` | `stakePressure` | Dodatkowe efekty |
| ------- | --------------: | ---------------- |
| `regular` | 0,5 | — |
| `playIn` | 1,0 | `crowdIntensity` +10 |
| `playoff` | 1,0 | `crowdIntensity` +15, `refereeStrictness` ×0,95 |
| `playoffElimination` | 1,4 | `crowdIntensity` +25, `λ` ×0,95 |
| `leagueFinal` | 1,6 | `crowdIntensity` +30 |

Wysoka stawka wzmacnia `clutchBonus` (§7.5) — zawodnicy z niską `determination` realnie zawodzą w playoff.

### 13.6 Zmęczenie kalendarzowe

Drugi mecz w tygodniu: startowa stamina niższa przez regenerację (`player_management.md`) + `contextMult` ×0,98 dla całej drużyny. Trzy mecze w 8 dni (playoff): ×0,96.

---

## 14. Losowość

### 14.1 Seed i determinizm

```text
matchSeed = hash(saveSeed, seasonYear, matchId)
```

Jeden `Random` na mecz, konsumowany w **stałej kolejności**. Ten sam seed + te same składy i decyzje = ten sam wynik. Wymagane dla:

- powtarzalności testów balansu,
- gwarancji, że **obserwowany mecz i mecz przesymulowany dają identyczny wynik** (§17),
- braku save-scummingu w obrębie jednej symulacji.

### 14.2 Warstwy losowości

| Warstwa | Mechanizm | Rola |
| ------- | --------- | ---- |
| Szum pojedynku | `N(0; DUEL_SIGMA = 6)` | upsety w pojedynczych starciach |
| Liczba sekwencji | Poisson(λ) | zmienna liczba akcji |
| Wybór typu sekwencji | ważone losowanie | różnorodność przebiegu |
| Wybór broniącego | ważone losowanie | eksploatacja słabych ogniw |
| Konwersja strzału | Bernoulli(xG × gkFactor) | wynik nie wynika liniowo z dominacji |
| Kontekst meczu | pogoda, sędzia, publiczność | zmienność między meczami |

### 14.3 Docelowy rozstrzęp

| Metryka | Cel |
| ------- | --: |
| Zwycięstwo faworyta przy przewadze 10 OVR średnio w XI | ~62% |
| Zwycięstwo faworyta przy przewadze 20 OVR | ~76% |
| Remisy | ~24% |
| Odchylenie standardowe goli drużyny | ~1,2 |
| Mecze, w których drużyna z mniejszym xG wygrywa | ~20% |

Poza tymi przedziałami tuningowi podlegają `DUEL_DISPERSION`, `DUEL_SIGMA` i lejek z §6.5.

---

## 15. Oceny i statystyki

### 15.1 matchRating

```text
rating = clamp(6,0 + Σ wkłady, 1,0, 10,0)
```

| Wkład | Δ |
| ----- | -: |
| Gol (ST / W) | +1,0 |
| Gol (CM / CAM) | +1,3 |
| Gol (DEF / GK) | +1,6 |
| Asysta | +0,7 |
| Wygrany pojedynek ofensywny | +0,05 |
| Wygrany pojedynek obronny | +0,06 |
| Przegrany pojedynek obronny prowadzący do gola | −0,45 |
| Obrona (GK) | +0,10 |
| Obroniony rzut karny (GK) | +1,2 |
| Czyste konto (DEF / GK, ≥60 min) | +0,6 |
| Gol samobójczy | −1,5 |
| Żółta kartka | −0,3 |
| Czerwona kartka | −1,5 |
| Zmarnowana duża sytuacja (xG > 0,4) | −0,25 |
| Poniżej 20 min na boisku | rating ważony przez minuty / 20 |

**Man of the Match:** najwyższy rating, minimum 7,0. Daje 20% szans na event „Inspirujący występ" (`player_management.md`).

### 15.2 Statystyki meczu

Per drużyna i per zawodnik: posiadanie, strzały, strzały celne, xG, podania, celność podań, pojedynki wygrane, faule, kartki, spaliny, rzuty rożne, obrony GK, minuty, gole, asysty, rating.

**xG jest jawne od pierwszego meczu** — widoczne na pasku statystyk w trakcie spotkania i w podsumowaniu pomeczowym. Nie wymaga odblokowania przez sztab ani dodatkowego slotu.

Agregowane do `seasonStats` (`player_management.md`) i tabeli ligowej.

---

## 16. Efekty pomeczowe

| Krok | Efekt |
| ---- | ----- |
| 1. Stamina | zużycie zapisane; **+20** natychmiastowej regeneracji (`player_management.md`) |
| 2. Forma | aktualizacja na podstawie ratingu (§16.1) |
| 3. Kontuzje | zapis typu i czasu trwania × `doctorCareMult` |
| 4. Kartki | inkrementacja liczników, ewentualne zawieszenia |
| 5. seasonStats | agregacja statystyk |
| 6. growthRate | +0,01 za każdą rozegraną minutę w tym tygodniu (`player_management.md`) |
| 7. Zgranie | delty per `team_management.md` |
| 8. Atmosfera | delty per `team_management.md` |
| 9. Eventy | rolle eventów losowych zawodnika i zespołu |
| 10. Wiadomości | `matchResult`, `injury`, `award` |

### 16.1 Aktualizacja formy

| Rating | Δ forma |
| ------ | ------: |
| ≥ 8,5 | +2 |
| 7,5 – 8,4 | +1 |
| 6,0 – 7,4 | 0 |
| 4,5 – 5,9 | −1 |
| < 4,5 | −2 |

Modyfikatory: `temperamental` po porażce ×1,5 na ujemnej delcie, brak występu (0 min) → drift −0,2 w stronę 6. Clamp 1–10.

---

## 17. Symulacja natychmiastowa

„Symuluj do końca" i symulacja meczów AI w tle używają **tego samego silnika i tego samego seeda**.

| Wymóg | Uzasadnienie |
| ----- | ------------ |
| Identyczny wynik jak przy obserwowaniu | brak przewagi z wyboru trybu; testowalność |
| Brak emisji tickerów UI | wydajność (29 tygodni × 15 meczów) |
| Decyzje gracza zamrożone na moment kliknięcia | symulacja od 60' uwzględnia dotychczasowe zmiany, dalsze nie |
| Drużyny AI: decyzje z `AI_behaviour.md` | spójność z meczami obserwowanymi |

Konsekwencja projektowa: **pętla minutowa nie może zależeć od stanu UI**. Symulacja żyje w `core/simulation`, UI tylko konsumuje strumień zdarzeń.

Cel wydajnościowy: pełna kolejka ligowa (15 meczów) < 150 ms na urządzeniu mobilnym.

---

## 18. Zdarzenia i feed

### 18.1 Katalog zdarzeń

| Zdarzenie | W feedzie | Priorytet |
| --------- | --------- | --------- |
| Gol | tak | wysoki |
| Asysta (razem z golem) | tak | wysoki |
| Rzut karny (przyznany / wykonany) | tak | wysoki |
| Czerwona kartka | tak | wysoki |
| Kontuzja | tak | wysoki |
| Duża sytuacja (xG > 0,4) | tak | średni |
| Obrona bramkarza po dużej sytuacji | tak | średni |
| Słupek / poprzeczka | tak | średni |
| Żółta kartka | tak | niski |
| Zmiana | tak | niski |
| Rzut rożny | nie | — |
| Zwykły pojedynek, podanie, faul | nie (tylko statystyki) | — |

Feed pokazuje maksymalnie ~25–35 wpisów na mecz.

### 18.2 Szkic UX

```
┌────────────────────────────────────────────────────────┐
│  DRUŻYNA A   2 : 1   DRUŻYNA B          67'    ☀ 22°C  │
├──────────────┬──────────────────────────┬──────────────┤
│ SKŁAD A      │  ZDARZENIA               │ SKŁAD B      │
│ 1 GK   7.2   │  67' Kontuzja: Nowak     │ 1 GK   6.8   │
│ 2 LB   6.9 ⚠ │  61' GOL! Kowalski (A)   │ 2 LB   7.1   │
│ 3 CB   7.5   │  58' Żółta: Lewy (B)     │ 3 CB   6.4   │
│ …            │  44' GOL! Adams (B)      │ …            │
│              │  22' GOL! Kowalski (A)   │              │
├──────────────┴──────────────────────────┴──────────────┤
│ Posiadanie 54% │ Strzały 11-8 │ xG 1.8-1.2            │
├────────────────────────────────────────────────────────┤
│  [⏸ Pauza]  [×1 ×2 ×4]  [Zmiany]  [Taktyka]  [→ Koniec]│
└────────────────────────────────────────────────────────┘
```

Wskaźnik ⚠ oznacza zawodnika wymagającego uwagi (niska stamina, ryzyko kartki, spadek ratingu).

---

## 19. Parametry balansu

Wszystkie stałe trafiają do `/balance` (`general_rules.md`). Wartości to punkt startowy do tuningu.

| Parametr | Wartość | Sekcja |
| -------- | ------: | ------ |
| `SHAPE_BASELINE` | 55 | §4 |
| `SHAPE_WEIGHT` | 0,0025 | §4 |
| `DUEL_DISPERSION` | 35 | §7.1 |
| `DUEL_SIGMA` | 6,0 | §7.1 |
| `SEQ_BASE` | 1,15 | §6.4 |
| `SEQ_TO_SHOT` | 0,22 | §6.5 |
| `SHOT_TO_GOAL` | 0,115 | §6.5 |
| `FOUL_BASE` | 0,085 | §8.1 |
| `YELLOW_FROM_FOUL` | 0,13 | §8.2 |
| `RED_DIRECT` | 0,007 | §8.2 |
| `INJURY_BASE` | 0,00018 | §10 |
| `CLUTCH_WEIGHT` | 1,2 | §7.5 |
| `MOMENTUM_DECAY` | 0,96 | §12.1 |
| `MOMENTUM_GOAL` | 25 | §12.1 |
| `SUB_LIMIT` | 5 | §11.2 |
| `SUB_WINDOWS` | 3 | §11.2 |
| `ROLE_FIT_BONUS` | 1,03 | §5.1 |
| `LEADER_BONUS` | 1,02 | §5.3 |
| `CARD_PRONE_TEMPERAMENTAL` | 1,35 | §8.1 |
| `INJURY_PROFESSIONAL` | 0,80 | §10 |
| `AERIAL_BASE` | 60 | §7.4, §7.6 |
| `AERIAL_SLOPE` | 1,2 | §7.4 |
| `AERIAL_CLAMP_MIN` | 35 | §7.4 |
| `AERIAL_CLAMP_MAX` | 85 | §7.4 |
| `AERIAL_DUEL_WEIGHT` | 0,15 | §7.4 |
| `AERIAL_EDGE_CLAMP` | 25 | §7.6 |
| `AERIAL_CORNER_COEF` | 0,006 | §7.6 |
| `AERIAL_FK_COEF` | 0,003 | §7.6 |

---

## 20. Kryteria akceptacji modelu

Symulacja 10 000 meczów na losowych składach musi spełniać:

| Metryka | Przedział docelowy |
| ------- | ------------------ |
| Gole na mecz | 2,4 – 2,9 |
| Zwycięstwa gospodarza | 48 – 55% |
| Remisy | 21 – 27% |
| Strzały na drużynę | 9 – 13 |
| Faule na drużynę | 9 – 13 |
| Żółte kartki na drużynę | 1,5 – 2,3 |
| Czerwone kartki na mecz | 0,08 – 0,16 |
| Kontuzje na mecz | 0,25 – 0,45 |
| Posiadanie skrajne (>65%) | < 8% meczów |
| Korelacja OVR XI ↔ punkty w sezonie | 0,65 – 0,80 |
| Zwycięstwo faworyta (+10 OVR) | 60 – 76% |

Korelacja poniżej 0,65 = zbyt losowa liga; powyżej 0,80 = zbyt deterministyczna.

---

## 21. Kolejność implementacji

| Etap | Zakres |
| ---- | ------ |
| 1 | Walidacja pre-match, walkower, `MatchContext` |
| 2 | `TeamShape` z `tactics.md`, `UnitRatings` z atrybutów |
| 3 | Pętla minutowa: posiadanie, sekwencje, rdzeń pojedynku |
| 4 | Mapowanie sytuacji → atrybuty (§7.4), model strzału i GK |
| 5 | Stamina live, zmiany, okno przerwy |
| 6 | Faule, kartki, zawieszenia, kontuzje |
| 7 | Momentum, stan meczu, kontekst pozaboiskowy |
| 8 | Oceny, statystyki, efekty pomeczowe |
| 9 | UI: feed, pauza, panele, symulacja do końca |
| 10 | Kalibracja na 10 000 meczów wg §20 |

---