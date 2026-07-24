### Kiedy odbywa się draft

- Draft jest częścią **offseasonu**, po zakończeniu play-off i finału ligi.
- **Loteria draftowa:** **piątek tygodnia 44** sezonu (`game_calendar.md` / `offseason.md`).
- **Tydzień 45:** Scout Report (pon) → Draft Combine (śr) → **Mock Draft finalny** (pt).
- **Właściwy draft** (3 rundy): **poniedziałek tygodnia 46** — okno wymian już otwarte od tyg. 44.
- Drużyna gracza wybiera zawodników ręcznie; pozostałe kluby draftują według logiki AI (`AI_behaviour.md`).
- Po drafcie (ten sam dzień): **generacja klasy N+1 (~120)** + **mock wstępny**; potem przedłużenia (**wt–niedz tyg. 46**), FA (**od pon tyg. 47**) + skauting ciągły.

### Struktura draftu

- **30 drużyn** — każda ma po **1 picku w każdej rundzie** (łącznie **90 wyborów**).
- **3 rundy** draftu.
- Pula talentów (**draft class**) liczy domyślnie **~120 prospektów**.
- ~30 niewybranych ląduje w Free Agency.


### Kto uczestniczy w loterii

- Do loterii **1. rundy** kwalifikuje się **10 najsłabszych drużyn** ligi, po 5 z każdej konferencji (drużyny spoza play-in/playoff).
- Pozostałe **20 drużyn** otrzymują picki **11–30** w **kolejności odwrotnej do miejsca w tabeli** (1. miejsce → pick #30).
- Ranking w loterii: najpierw **mniej punktów**, przy remisie **gorsza różnica bramek** → **mniej strzelonych bramek** → **bilans bezpośredni** → **więcej zwycięstw** → **rzut monetą**.


### Loteria 1. rundy (ważone szanse)

Wzorowana na NBA: każda z **10** drużyn ma wagę szans na **kolejny** wolny pick (losowanie bez zwracania).


| Miejsce wśród 10 (od najgorszego) | Waga |
| -------------------------------- | ---- |
| 1–3                              | 140  |
| 4                                | 125  |
| 5                                | 105  |
| 6                                | 90   |
| 7                                | 75   |
| 8                                | 60   |
| 9                                | 45   |
| 10                               | 30   |


- Najgorszy rekord ma **najwyższą** szansę na wczesny pick, ale **nie ma gwarancji** picka #1.
- Po loterii do kolejności dołączane są picki **11–30** według odwrotnej kolejności tabeli.


### Kolejność picków w rundach 2 i 3

- **Runda 1:** loteria (1–10) + picki 11–30 według odwrotnej kolejności tabeli.
- **Runda 2 i 3:** **odwrócona** kolejność z tabeli — 1. miejsce → ostatni pick rundy (#60/#90).


### Pula prospektów (draft class)

- Prospekci generowani **zaraz po zakończeniu draftu** poprzedniej edycji (klasa na rok N+1).
- Seed / nowa kariera: pierwsza klasa generowana przy starcie save’a (przed pierwszym draftem) + od razu mock wstępny.
- **Wiek:** 18–20 lat.
- **Pozycje:** losowe z puli.
- **Narodowość:** imię i nazwisko z puli kraju — `national_names.md`.
- Ukryte: potencjał ★, `injuryProne`, `determination`, `overallProgress`, `growthRate` — `player_management.md`.
- Atrybuty bazowe / potencjał maleją wraz z true rankem klasy.


### Dwa mock drafty

Oba ustalają **kolejność wyświetlania** (nie kolejność picków klubów). True board = ukryty ranking jakości klasy.

#### Mock wstępny (po generacji klasy)

- Moment: wieczór **poniedziałku tyg. 46** (po drafcie) — dla klasy N+1.
- Większa wariancja true rank → displayed rank:

| True projected band | Typowy zakres odchylenia |
| ------------------- | ------------------------ |
| Top / wczesna R1 | ± **10–15** miejsc |
| Środek boardu | ± **15–22** |
| Projected R3 / undrafted | ± **25–30** |

#### Mock finalny (piątek tyg. 45)

- Mniejsza wariancja (top ±8–12, R3 ±18–25) — szczegóły: `offseason.md`.
- Wejścia: rok rozwoju prospectów, kontuzje, Combine, szum medialny, skauting ligi.
- Sort UI listy na draft = mock finalny.
- Scout dopina estymowane sloty (`Top 1` … `X`) dla obserwowanych — `staff_rules.md`.

Mock **nie** jest binding dla AI (`AI_behaviour.md`).


### Scouting i oceny

| Ocena | Znaczenie |
| ----- | --------- |
| `scoutGrade` | Raport skautów — zaszumiony do podniesienia tieru |
| `combineScore` | Wyniki testów Combine (jawne po Combine) |

- Skauting ciągły od FA (tyg. 47) — limit **Coverage**; jakość **Evaluation** — `staff_rules.md`.
- Lista UI sortowana według aktualnego mocku (wstępny → po Mock 2 finalny).
- `combineScore` może odbiegać od `scoutGrade`.


### Kontrakty rookie scale

Nowo wybrani podpisują **kontrakt rookie scale** — pensja od numeru picka.

- **Długość:** 2 lata.
- **Formuła:** `baseScale / (1 + pickSlot × 0,08)`, `baseScale = 8 000 000 €`.
- **Zakres:** min. **500 000 €**, max. **8 000 000 €**.
- Flagi: `isRookieScale`, `rookiePickSlot`.

Przykładowe pensje:

| Pick | Pensja (€) |
| ---- | ---------- |
| 1    | ~7 400 000 |
| 10   | ~5 000 000 |
| 20   | ~3 200 000 |
| 30   | ~2 350 000 |

- Rookie scale nie wymaga wolnego cap space ponad kwotę kontraktu.
- Po 2 latach: **RFA** z Qualifying Offer i prawem match — `salary_cap_rules.md` § RFA.
- ROTY w następnym offseasonie: cała klasa (draftowani + niedraftowani z FA) — `offseason.md`.


### Picki jako aktywa

- Handel pickami 1.–3. rundy — `trade_rules.md`.
- Reguła Stepiena i ochrony lottery.
- Po wymianie picka nowy właściciel draftuje w ustalonej kolejności.


### Po drafcie

- Wybrani → roster (walidacja ≤ 30; bez min. GK) + payroll.
- Historia: `draftPicks`.
- Generacja klasy N+1 + mock wstępny.
- Potem przedłużenia i FA — `game_calendar.md`, `contract_signing.md`.
