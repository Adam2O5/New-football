# Matchday — model symulacji meczu

Dokument opisuje **docelowy** model dnia meczowego i minutowej symulacji.  
Wzorzec UX: **FIFA 15 Career Mode** (składy po lewej, feed wydarzeń po prawej), z możliwością **pauzy i zmian w składzie / taktyce**.

Status: **projekt** (obecny kod: uproszczony `MatchEngine` — minutowa pętla bez pauzy i bez pełnych zależności zdarzeń).  
Wagi bazowe i mnożniki będą **dostrajane później** — tu definiujemy strukturę, czynniki i reguły zależności.

Powiązane: `staff_rules.md`, `AI_behaviour.md`, `game_calendar.md`, `tactics.md`, `squad_management.md`, `player_management.md`.

---

## UX — ekran meczu (FIFA 15 + pauza)

```
┌─────────────────────────┬──────────────────────────────────┐
│  SKŁADY / TAKTYKA       │  FEED WYDARZEŃ                   │
│                         │                                  │
│  Dom  vs  Wyjazd        │  12'  [Ż] Kowalski               │
│  Formacja 4-3-3         │  23'  GOL Nowak (asysta …)       │
│  XI + ławka             │  31'  Kontuzja — Smith           │
│  Role / instrukcje      │  45+1' Koniec I połowy           │
│                         │  …                               │
│  [Pauza] [Wznowij]      │  wynik na żywo + xG / strzały    │
│  [Zmiana] [Taktyka]     │                                  │
└─────────────────────────┴──────────────────────────────────┘
```

### Pre-check przed meczem

1. **Roster 20–30** — jeśli nie: **walkower 0–3** (bez symulacji minutowej) — `squad_management.md`. Nie mylić z karą braku BR.
2. **Slot bramkarza w XI** — jeśli w bramce nie ma zawodnika z `Position.gk` (zawodnik z pola / pusty slot uzupełniony outfieldem): mecz może być „rozegrany” skróconą ścieżką z **twardym wynikiem w stylu 0–5** na niekorzyść drużyny bez BR (feed: „brak bramkarza — ogromna kara”). Obie strony bez GK → 0–0 lub osobna reguła (v1: obie dostają karę ofensywną / wynik 0–0 bez punktów).
3. Legalny roster + GK w bramce → normalna symulacja.

### Przebieg z perspektywy gracza

1. **Przed meczem** — skład XI, ławka, taktyka, role; podgląd rywala i kontekstu (derby, pogoda, stawka); pre-check powyżej.
2. **Start symulacji** — silnik idzie **minuta po minucie**; po prawej pojawiają się zdarzenia.
3. **Pauza** — w dowolnym momencie (lub auto-pauza przy krytycznym zdarzeniu — opcja):
   - zmiany zawodników (limit zmian jak w regulaminie ligi),
   - korekta taktyki / formacji / ról,
   - ewentualnie instrukcje indywidualne.
4. **Wznowienie** — od następnej minuty z **zaktualizowanym stanem meczu** (skład, siła, morale).
5. **Koniec** — wynik, statystyki, aktualizacja formy / staminy / kontuzji / development.

AI przeciwnika może też dokonywać zmian w swoich „oknach” (np. przerwa, czerwona kartka, kontuzja) — na Hard agresywniej (`AI_behaviour.md`).

---

## Architektura silnika

### Jednostka czasu

- Symulacja idzie w pętli `minute = 1 … 90` (+ ewentualny czas doliczony / dogrywka w pucharach).
- Każda minuta: **jeden roll** (lub łańcuch rolli) decydujący, czy i jakie zdarzenie wystąpi.
- Większość minut = brak widocznego zdarzenia (posiadanie / „cisza” w feedzie).

### Stan meczu (`MatchState`)

Stan mutowalny między minutami; pauza i zmiany go aktualizują.

| Pole | Opis |
| ---- | ---- |
| `minute` | bieżąca minuta |
| `score` | gole dom / wyjazd |
| `homeXI` / `awayXI` | aktualne składy (po zmianach) |
| `bench` | ławki + zużyte zmiany |
| `tactics` | taktyki obu stron |
| `cards` | żółte / czerwone per zawodnik i drużyna |
| `onPitchCount` | liczba zawodników (start 11; −1 przy czerwonej) |
| `injuriesThisMatch` | lista urazów |
| `momentum` | krótkoterminowy momentum (−1…+1) po golach / kartkach |
| `moraleMod` | modyfikator atmosfery z przebiegu meczu |
| `context` | derby, pogoda, ranga meczu, home advantage |
| `rngSeed` | powtarzalność / replay (opcjonalnie) |

### Wynik końcowy

Jak dziś: `MatchResult` — wynik, zdarzenia, statystyki drużynowe i indywidualne, xG, posiadanie itd.

---

## Typy wydarzeń

Rozszerzenie względem obecnego `MatchEventType`:

| Typ | Widoczne w feedzie | Uwagi |
| --- | ------------------ | ----- |
| `goal` | tak | z asystą opcjonalnie |
| `shotOffTarget` / `shotOnTarget` | opcjonalnie (szum feedu) | lub tylko agregat w panelu |
| `chanceCreated` | opcjonalnie | „duża okazja” |
| `corner` | tak / zagregowane | |
| `foul` | rzadko | zwykle tylko przy kartce |
| `yellowCard` | tak | |
| `redCard` | tak | bezpośrednia lub 2× żółta |
| `penaltyAwarded` | tak | potem `scoredPenalty` / `missedPenalty` |
| `minorInjury` | tak | zawodnik może zostać / zejść |
| `majorInjury` | tak | wymuszona zmiana / bez zmiany jeśli brak |
| `substitution` | tak | decyzja gracza lub AI |
| `tacticalChange` | opcjonalnie | po pauzie |
| `halfTime` / `fullTime` | tak | znaczniki faz |

Wagi bazowe `P(event | minute, state)` — **placeholder**; strojenie w kodzie silnika.

---

## Losowanie zdarzenia w minucie

### Krok 1 — kontekst minuty

Oblicz **siłę ofensywną / defensywną** obu drużyn z aktualnego XI:

```
playerContribution = overall
                   × staminaFactor   // 0–100; w kodzie legacy: fitness
                   × formFactor      // 1–10 → np. form/5
                   × roleMult        // boost/kara AssignedRole (nie mylić z pozycją)
                   × chemistryMult   // zgranie drużyny — squad_management.md
```

Agregacja drużynowa uwzględnia:

- formację i taktykę (`def`/`mid`/`atk`, tempo, pressing, szerokość, linia — `tactics.md`),
- kontr-taktykę vs rywal,
- atmosferę / morale,
- zgranie składu,
- czynniki meczowe (derby, pogoda, ranga),
- stan meczu (liczba graczy, momentum, zmęczenie minutą).

### Krok 2 — wybór „wiadra” zdarzenia

Roll `u ~ U(0,1)` względem wag (przykład struktury, nie finalne liczby):

| Wiadro | Przykład wagi bazowej | Komentarz |
| ------ | --------------------- | --------- |
| Cisza / posiadanie | wysoka | większość minut |
| Akcja bramkowa | średnia | strzał → celny → gol |
| Stały fragment | niska | rożny, rzut wolny |
| Faul / kartka | niska | zależna od pressingu |
| Kontuzja | bardzo niska | × `injuryProne` |
| Inne | niska | |

Wagi są **mnożone** przez modyfikatory z czynników (poniżej) i przez **zależności stanu**.

### Krok 3 — rozstrzygnięcie wewnątrz wiadra

Np. akcja bramkowa:

1. Która drużyna atakuje? (posiadanie / attackBias)
2. Kto kończy / asystuje? (pozycja, rola, `shooting` / `passing`, forma)
3. xG okazji → strzał celny → gol / obrona BR
4. Dopisz `MatchEvent` + zaktualizuj `MatchState` (score, momentum, morale)

---

## Czynniki wpływające na wagi

Wszystkie czynniki skalują wagi lub siłę — dokładne współczynniki **TBD**.

### A. Formacja i taktyka

| Element | Wpływ (kierunek) |
| ------- | ---------------- |
| Formacja ofensywna (np. 4-3-3, 3-4-3) | ↑ okazje własne, ↑ ryzyko kontr |
| Formacja defensywna (np. 5-4-1, 4-5-1) | ↓ okazje rywala, ↓ własne |
| Tempo `fast` | ↑ akcje, ↑ faule, ↑ zmęczenie |
| Tempo `slow` | ↓ akcje, ↓ kontuzje przeciążeniowe |
| Pressing wysoki / gegenpressing | ↑ odzyskania, ↑ faule / kartki |
| Linia obrony wysoko | ↑ okazje własne i kontrówki rywala |
| Szerokość | wpływa na rożne / krzyżowe / środek |

### B. Atmosfera w zespole (`atmosphere` / morale)

Źródło prawdy sezonowej: `squad_management.md`.  
W meczu dodatkowo krótkie wahania: gol (+), czerwona (−), kontuzja gwiazdy (−), remis w derbach (±).  
Niska atmosfera → ↓ skuteczność wykończenia, ↑ szansa błędu / kartki nerwowej.

### C. Zgranie (chemistry)

Źródło prawdy: `squad_management.md`.  
Budowane przez **optymalne pozycje** (nie role), czas razem, osobowości, trenerów, narodowość i dryf atmosfery.  
W meczu: wysokie zgranie → ↑ celność podań, ↓ chaosu przy pressingu; skład „sklejony ad hoc” → większa wariancja.  
Efekt na atrybuty: `chemistryMult` (efektywne FUT), nie permanentny overall.

### D. Jakość zawodników i role

- `overall`, atrybuty FUT, rola (`AssignedRole`) — `player_management.md` / `tactics.md`.
- **Pozycja** ≠ **rola**: zła pozycja bije w zgranie; zła/dobra rola daje `roleMult` (boost / kara fit).
- BR: osobna oś na rzuty karne i strzały celne.
- **Brak BR w bramce** (outfield na GK): nie symuluj normalnego meczu — zastosuj **karę wyniku ~0–5** (sekcja Pre-check). To osobna reguła od walkoweru rosteru.

### E. Forma i stamina

- Forma (`form`, **1–10**) — krótki hot/cold streak (`player_management.md`).
- Stamina (0–100) — spada z minutami; niska ↑ kontuzje i ↓ contribution w końcówce.

### F. Czynniki meczowe

| Czynnik | Wpływ |
| ------- | ----- |
| **Derby / rywal** | ↑ intensywność: faule, kartki, momentum; większa wariancja wyniku |
| **Pogoda** (deszcz, śnieg, upał) | ↓ precyzja / tempo; upał ↑ kontuzje i zmęczenie |
| **Ranga** (liga, play-in, finał) | finał ↑ napięcie (kartki, pomyłki) lub ↑ skupienie (TBD) |
| **Home advantage** | lekki bonus siły / morale gospodarzy |
| **Rest days** | krótki odpoczynek ↑ kontuzje, ↓ stamina startowa |

### G. Losowość

- Każdy roll ma szum — nawet duża przewaga nie gwarantuje gola.
- Na poziomie trudności Hard AI lepiej zarządza składem; **nie** dostaje ukrytego RNG buffa meczowego (fair sim).

---

## Zależności zdarzeń (łańcuchy stanu)

Kluczowa różnica względem niezależnych rolli: **historia meczu zmienia przyszłe wagi**.

| Warunek stanu | Efekt (kierunek; waga TBD) |
| ------------- | -------------------------- |
| Drużyna gra w **10** (1 czerwona) | znaczący ↓ szansy na gol tej drużyny; ↑ szansa gola rywala; ↑ zmęczenie pozostałych |
| Drużyna gra w **9** | efekt silniejszy; AI / gracz pod aut-pauzą do zmiany taktyki |
| Żółta kartka u zawodnika | ↑ szansa drugiej żółtej / ostrożniejszy pressing u niego |
| Gol zdobyty | krótki ↑ momentum strzelców; lekki ↓ skupienia rywala ALBO ↑ reaction (profil) |
| Gol stracony w końcówce | ↑ ryzykowne ustawienie przegrywających (więcej okazji obu stron) |
| Kontuzja kluczowego | ↓ siła; morale↓; wymuszona zmiana zużywa slot |
| Dużo fauli już w meczu | sędzia „ostrzejszy”: ↑ waga kartki przy kolejnym faulu (opcjonalnie) |
| Prowadzenie 2+ bramek | ↓ agresja lidera (mniej otwarcia), chyba że taktyka agresywna |
| Rzut karny | osobny roll; niezależny od xG otwartej gry, zależny od `shooting` / mental / forma |

**Przykład:** po pierwszej czerwonej kartce drużyny A mnożnik `goalWeight(A) *= 0.55` (placeholder), `goalWeight(B) *= 1.25`, do końca meczu lub do kolejnej zmiany stanu.

Zależności są **kompozycyjne** (mnożniki się składają), z clampem, żeby mecz nie „umierał” numerycznie.

---

## Pauza i zmiany składu

### Zasady

- Gracz może pauzować w każdej minucie (limit spamowania UI — np. nie częściej niż co N sekund realnych, bez limitu strategicznego).
- **Auto-pauza (opcjonalnie w ustawieniach):** czerwona, kontuzja XI, gol, przerwa.
- Limit zmian: **maks. 5 zmian** w meczu, w **maks. 3 oknach** zmian (jak regulamin ligi; pauza / przerwa / kontuzja zużywają okno gdy dokonano ≥1 zmiany w danym oknie).
- Po zmianie: przelicz `MatchState` contribution; feed dostaje event `substitution`.

### Czego nie wolno w pauzie

- Cofać czasu / anulować zdarzeń już zapisanych.
- Zmieniać wyniku.
- Lepiej: resetować momentum sztucznie — momentum wynika tylko z gry.

---

## Interfejs danych (kierunek implementacji)

```text
MatchEngine.simulateMinute(MatchState state, Random rng)
  → MinuteOutcome(events, stateDelta)

MatchEngine.runUntil(state, targetMinute | pauseCondition)
  → umożliwia UI pauzę i podmianę lineup/tactics
```

Obecne `simulateMatch(setup, rng)` zostaje jako **fast-forward** (AI vs AI, wynik bez UI) albo owija pętlę minutową bez pauzy.

---

## Mapowanie na obecny kod

| Element | Dziś | Docelowo |
| ------- | ---- | -------- |
| Pętla 1–90 | ✅ | ✅ + pauza |
| Siła: overall × stamina × form | częściowo (legacy fitness/form) | + role, chemistry, atmosphere, context |
| Zdarzenia niezależne wagami stałymi | ✅ | wagi × stan × zależności |
| Czerwona → wpływ na kolejne gole | ❌ | ✅ |
| Pauza / zmiany w trakcie | ❌ | ✅ |
| `injuryProne` | ❌ | ✅ przy tworzeniu zawodnika |
| Derby / pogoda | ❌ | ✅ w `MatchContext` |
| Feed UI split-view | częściowo ekran wyniku | ekran matchday na żywo |

---

## Strojenie (później)

Do wyciągnięcia do stałych / tabel balansu:

1. Wagi bazowe wiader na minutę.
2. Mnożniki formacji i taktyki.
3. Mnożniki czerwonej kartki / 10 vs 11.
4. Krzywa `injuryProne` → P(injury).
5. Wpływ morale i chemistry (clamp).
6. Intensywność derby i pogody.

Do czasu strojenia implementacja może używać placeholderów oznaczonych w kodzie.
