# Offseason — reguły eventów

Dokument projektowy: dokładne zasady działania wydarzeń po finale ligi (tyg. **44+**).  
Terminy kotwic: `game_calendar.md`. Struktura draftu / loterii: `draft_rules.md`. Cap / Bird / MLE: `salary_cap_rules.md`. Skauting / sztab: `staff_rules.md`. Kontrakty: `contract_signing.md`. Inbox: `messages.md`.

Status: **projekt**.

---

## 1. Zakres i kolejność

Offseason zaczyna się po niedzieli tyg. **43** (koniec finału ligi). Eventy są **sekwencyjne** — późniejszy nie startuje, dopóki wcześniejszy nie domknie stanu gry (chyba że oznaczono jako równoległy).

| # | Event | Moment | Faza UI |
| - | ----- | ------ | ------- |
| 0 | Staff growth / retire | Po finale tyg. **43**, przed Awards | Powiadomienia sztabu |
| 1 | Awards | Poniedziałek tyg. **44** | Ceremonia |
| 2 | Retirements | Środa tyg. **44** | Decyzje / powiadomienia |
| 3 | Lottery | Piątek tyg. **44** | Loteria live |
| 4 | Scout Report | Poniedziałek tyg. **45** | Raporty + assign Combine |
| 5 | Draft Combine | Środa tyg. **45** | Combine |
| 6 | Mock Draft (finalny) | Piątek tyg. **45** | Board / ranking |
| 7 | Draft | Poniedziałek tyg. **46** | Draft board (3 rundy) |
| 7b | Generacja klasy N+1 + mock wstępny | Po drafcie, ten sam dzień | Board klasy następnej |
| 8 | Contract extensions | Wt–niedz tyg. **46** | Negocjacje Bird + staff |
| 9 | Free agency open | Poniedziałek tyg. **47** | FA market (10h/dzień) + skauting ciągły |
| 10 | Przygotowania | Tyg. **47** → tyg. **1** | Treningi, trades, roster |

Równolegle od poniedziałku tyg. **44** (po finale): **okno wymian** (`trade_rules.md`) — trwa do trade deadline tyg. 23.

---

## 2. Awards (poniedziałek tyg. 44)

### Cel

Przyznanie nagród indywidualnych i zespołowych za zakończony sezon. Odblokowane po finale (tyg. 43) i po rollu sztabu (event #0).

### Progi minutowe

`possibleMinutes` = 58 × 90 = **5220** (sezon regularny). Progi liczą tylko **minuty sezonu regularnego**, o ile nie zaznaczono inaczej.

| Nagroda | Próg minut (regular) | Uwagi |
| ------- | -------------------- | ----- |
| **MVP** | ≥ **40%** (~≥ 2088 min) | poniżej progu: wykluczenie |
| **ROTY** | ≥ **25%** (~≥ 1305 min) | klasa draftowa roku N−1 |
| **DPOY** | ≥ **40%** | wykluczenie poniżej progu |
| **Król strzelców** | ≥ **30%** | inaczej nie kwalifikuje się |
| **Król asyst** | ≥ **30%** | j.w. |
| **Najlepszy BR** | ≥ **40%** jako `Position.gk` | minuty tylko w bramce |
| **Team of the Season** | ≥ **30%** na danym slocie | osobno per slot 4-3-3 |
| **Coach of the Year** | — | brak progu minut |

Progi i wagi — do strojenia w kodzie; ten dokument jest kanonem reguł.

### Kategorie i formuły

Wszystkie score są **względne** (ranking); konkretne wagi — projekt do tuningu.

#### MVP

```text
mvpScore =
  0.35 × teamPtsShare      // udział w punktach drużyny gdy zawodnik w XI / na boisku
+ 0.25 × ratingAvg         // średni rating meczowy (regular)
+ 0.20 × (goals + assists) / 90min
+ 0.10 × playoffBonus      // lekki bonus; waga ≤ regular
+ 0.10 × overallNorm       // overall znormalizowany 50–99 → 0–1
```

#### Rookie of the Year (ROTY)

- Kwalifikacja: zawodnicy z **klasy draftowej poprzedniego roku** (wygenerowani do draftu N−1) — zarówno **draftowani** (rookie scale), jak i **niedraftowani**, którzy trafili do FA i rozegrali sezon.
- Formuła jak MVP, ale `playoffBonus × 0.5` (lub 0 w v1).
- Próg minut: **25%**.

#### Defensive Player of the Year (DPOY)

```text
dpoyScore =
  0.40 × defRating
+ 0.25 × cleanSheetShare     // udział w czystych kontach gdy na boisku
+ 0.20 × (tackles + interceptions)Norm
+ 0.15 × (1 − goalsConcededWhenOnNorm)  // mniej straconych przy zawodniku = lepiej
```

#### Coach of the Year

```text
coachScore = ΔwinsVsProjected + placeVsPreseasonSeed
```

Dla AI i gracza ta sama metryka (`staff_rules.md` — Head Coach).

#### Król strzelców / Król asyst

- Zwycięzca: max `goals` / max `assists` w sezonie regularnym wśród spełniających próg minut.
- Tie-break: **mniej minut**, potem druga statystyka (asysty / gole), potem rating.

#### Najlepszy bramkarz

```text
gkScore =
  0.45 × savePct
+ 0.25 × cleanSheetsNorm
+ 0.20 × goalsPreventedNorm
+ 0.10 × ratingAvg
```

Tylko minuty na pozycji GK.

#### Team of the Season (formacja 4-3-3)

Sloty:

| Slot | Mapowanie pozycji zawodnika |
| ---- | --------------------------- |
| GK | `gk` |
| LB | `lb`, **`lwb`** |
| CB | `cb` (najlepszy CB; przy dwóch CB w XI — dwa niezależne rankingi: CB1/CB2 po score) |
| RB | `rb`, **`rwb`** |
| MID × 3 | dowolne z `cdm` / `cm` / `cam` (mogą być np. trzech CAM) |
| LW | `lw` |
| ST | `st` |
| RW | `rw` |

Dla każdego slotu: najwyższy `positionScore` (rating + wkłady typowe dla linii) wśród zawodników spełniających próg **30%** minut **zaliczanych do tego slotu** (minuty rozegrane na mapowanej pozycji). Zawodnik może wejść tylko do **jednego** slotu (priorytet: najwyższy score wśród slotów, na które kwalifikuje).

#### Champion

Automat po finale ligi (drużyna mistrzowska).

### Przebieg

1. Silnik liczy rankingi (regular + playoff z wagą ≤ regular tam, gdzie dotyczy).
2. UI: podium / top 5 per kategoria + XI sezonu.
3. Zapis `seasonAwards`.
4. Lekki wpływ na atmosferę / morale — `squad_management.md`.
5. Wiadomość z czerwoną flagą (domyślnie ważna) — `messages.md`.

Sixth Man / Impact Sub: poza zakresem — `Może_kiedyś_do_dodania.md`.

---

## 3. Retirements (środa tyg. 44)

### Cel

Zawodnicy kończą karierę; schodzą z rosterów przed draftem i FA.

### Model: tabela prawdopodobieństwa (wiek 33+)

Roll **raz na zawodnika** na koniec sezonu (event Retirements). Bazowa szansa zależy od wieku ukończonego w tym sezonie:

| Wiek | P_base (emerytura) |
| ---- | -----------------: |
| ≤ 32 | **0%** (wyjątki &lt; 1% tylko przy ekstremalnym major injury + jawna prośba — osobny roll) |
| 33 | 3% |
| 34 | 8% |
| 35 | 18% |
| 36 | 32% |
| 37 | 55% |
| 38 | 78% |
| 39+ | 95% |

```text
P_final = clamp(P_base + ΣΔ_add + P_base × ΣΔ_mult, 0%, 99%)
```

### Modyfikatory (projekt)

| Czynnik | Wpływ (orientacja) |
| ------- | ------------------ |
| Spadek overall w sezonie | +3 pp za każdy −1 OVR (cap +25 pp) |
| Mało minut (&lt; 20% possible) | +12 pp |
| Minuty 20–35% | +5 pp |
| Major injury w sezonie | +10 pp (kolejne major +5 pp) |
| Minor × wiele | +2…6 pp |
| Osobowość `ambitious` przy braku minut / slocie | +5 pp |
| Osobowość `loyal` / `professional` | −4 pp |
| Średnia `atmosphere` sezonu &lt; 40 | +8 pp |
| Atmosfera ≥ 80 | −5 pp |
| Brak awansu do playoff (drużyna) | +6 pp |
| Deep playoff (finał konf.+) | −4 pp |

**Cel balansu:** poniżej 33 prawie nigdy; średni wiek odejścia **35–36**; tylko ~**1%** zawodników nadal gra w wieku **38**. Strojenie: `player_management.md` / kod.

### Skutki

1. Usunięcie z `roster`; kontrakt wygasa bez FA.
2. Roster może wyjść poza **20–30** — **jedyna** droga poza limit to emerytura (trade/FA/draft nie mogą tego zrobić). Przy nielegalnym rosterze w dniu meczu: **walkower** — `squad_management.md`.
3. Zwolnienie cap space.
4. **Bramkarz:** brak hard-min liczby GK. Klub ma czas **do poniedziałku tyg. 1** na podpisanie następcy (FA / trade). Do startu sezonu wolno grać bez BR w kadrze; w meczu bez GK w bramce obowiązuje kara wyniku — `matchday_model.md`.
5. Wiadomość (ważna dla własnych zawodników).

AI nie blokuje emerytury — decyzja zawodnika (roll).

---

## 4. Lottery (piątek tyg. 44)

### Cel

Ustalenie kolejności picków **1–10** 1. rundy. Picki **11–30** według tabeli (odwrotna kolejność).

Szczegóły: `draft_rules.md`.

### Przebieg

1. Ranking „najgorszych” 10 wg punktów / tie-breakerów.
2. Losowanie bez zwracania z wagami (1–3: 140 … 10: 30).
3. UI: odsłanianie od #10 do #1.
4. Zapis kolejności 1. rundy + właścicieli picków.

### Po loterii

- Drużyny znają slot; AI aktualizuje cele draftowe.
- Prospect pool klasy bieżącej (**120**) istnieje od **poprzedniego** draftu (generacja po drafcie N−1) i jest już skautowany od FA.

---

## 5. Scout Report (poniedziałek tyg. 45)

### Cel

1. Pokazanie listy obserwowanych prospectów z **całą wiedzą** zebraną przez scouta od startu skautingu (FA tyg. 47 poprzedniego cyklu).
2. **Przypisanie scouta** do obserwacji wybranych prospectów na **Draft Combine** (środa tyg. 45).

### Przebieg

1. UI: lista watchlist z tierami / `scoutGrade` / estymacjami / notatkami — jakość zależna od **Evaluation** scouta (`staff_rules.md`).
2. Gracz (i AI) wybiera cele Combine: limit ≈ **½ Coverage** (zaokrąglenie w dół, min 1 jeśli Coverage ≥ 1).
3. Nieprzypisany prospect i tak uczestniczy w Combine, ale klub **nie dostaje** bonusowego odczytu `injuryProne` / `determination` ani notatek Combine.
4. Auto-assign AI: potrzeby pozycji + najwyższy projected pick w zasięgu.

### Output

- Snapshot wiedzy scouta (do inboxa / ekranu).
- `combineAssignments` (scout → prospectIds).

Skauting ciągły (assign poza Combine): od FA — `staff_rules.md`.

---

## 6. Draft Combine (środa tyg. 45)

### Cel

1. **Mecz pokazowy** — 2 najlepsi na każdej pozycji (wg mocku wstępnego / bieżącego boardu).
2. **Testy fizyczne i medyczne** — cała klasa (120).

### Mecz pokazowy

- Top-2 per `Position` (remis: wyższy mock, potem overall).
- Skrócona symulacja → wpływ na `combineScore` / percepcję.
- Bez major injury (śladowe minor).

### Testy

| Wynik | Wpływ |
| ----- | ----- |
| `combineScore` | jawny po Combine |
| Flagi medyczne | podgląd `injuryProne` z szumem |
| Pomiary | wzrost / waga / athletic band |

Scout z `combineAssignments`: wyższa szansa poprawnego odczytu `injuryProne` i `determination` (Evaluation).

### Po Combine

- UI wyników; AI aktualizuje board wewnętrzny.
- Dane zasilają **Mock Draft finalny** (pt 45).

---

## 7. Mock Draft — finalny (piątek tyg. 45)

### Cel

**Druga, finalna** publiczna lista — sort UI prospectów na draft. Uwzględnia: rok rozwoju, kontuzje, Combine, szum medialny, dotychczasowy skauting.

### Wariancja (mniejsza niż mock wstępny)

True rank → displayed rank z noise:

| True projected band | Typowy zakres odchylenia |
| ------------------- | ------------------------ |
| Top / wczesna R1 | ± **8–12** miejsc |
| Środek R1–R2 | ± **12–18** |
| R3 / undrafted range | ± **18–25** |

(Mock wstępny ma większe wahania — §8 / `draft_rules.md`.)

### Zasady

- Sort UI = pozycja w mocku finalnym.
- Nie binding dla AI w dniu draftu (`AI_behaviour.md`).
- Scout dopina każdemu **obserwowanemu wcześniej** prospectowi estymowany slot: `Top 1` · `Top 3` · `Top 5` · `Top 10` · `R1` · `R2` · `R3` · `X` — dokładność rośnie z Evaluation i czasem obserwacji.

---

## 8. Draft (poniedziałek tyg. 46)

### Cel

3 × 30 = **90** wyborów — `draft_rules.md`.

### Równolegle

- Okno wymian już otwarte od tyg. **44** (`trade_rules.md`).
- Trade picków w trakcie draftu (v1: między rundami).

### Przebieg

1. Board posortowany wg **mocku finalnego**; dane Combine widoczne.
2. Pick gracza: pauza UI.
3. AI: potrzeby pozycji, scout knowledge, potencjał (`AI_behaviour.md`).
4. Wybrany: rookie scale 2 lata; walidacja roster ≤ **30** (bez min. GK).
5. Zapis `draftPicks`.

### Po drafcie (ten sam dzień)

1. ~30 niewybranych → pula FA (od tyg. 47).
2. Payroll += pensje rookie.
3. **Generacja nowej klasy (120 prospectów)** na draft N+1.
4. **Mock wstępny** tej klasy (większa wariancja: top ±10–15, R3 ±25–30) — `draft_rules.md`.
5. Od wtorku: okno przedłużeń.

---

## 9. Contract extensions (wtorek–niedziela tyg. 46)

### Cel

Przedłużenie własnych zawodników (Bird) oraz negocjacje **sztabu** w tym samym rytmie godzinowym co FA — szczegóły: **`contract_signing.md`**.

### Kto (zawodnicy)

- `hasBirdRights` lub `seasonsWithTeam ≥ 3` — `salary_cap_rules.md`.
- v1: tylko wygasający kontrakty.

### Przebieg (skrót)

- 10 godzin / dzień; 1 oferta / godzinę (gracz i AI równolegle).
- Reakcje: Accept / Hard reject / Waiting / Counter.
- Powyżej cap: wyjątek Bird; walidacja apronów.
- Odrzucenie / brak oferty → FA tyg. 47.

### Zamknięcie

Niedziela tyg. **46** — koniec okna Bird. Niewykorzystane Bird na wygasających: utrata przedłużenia powyżej cap.

---

## 10. Free agency open (poniedziałek tyg. 47)

### Cel

Rynek FA + niedraftowani + wygasłe bez przedłużenia; start **ciągłego skautingu** klasy N+1; zatrudnianie sztabu — `contract_signing.md`, `staff_rules.md`.

### Start dnia

1. **Reset MLE** (`midLevelExceptionAvailable = true`) — `salary_cap_rules.md`.
2. Publikacja puli FA.
3. Odblokowanie assignu scouta do prospectów (limit = Coverage).
4. Rytm **10h/dzień** podpisów (w tym offer sheet / RFA match).

### Zasady podpisów

- Cap / Bird / MLE jak w `salary_cap_rules.md`.
- Roster: **20–30** po operacji; brak min. GK.
- AI: `AI_behaviour.md`.

### Do tyg. 1

- FA aktywne; AI mniej agresywne pod koniec.
- Domykanie rosteru (w tym BR po emeryturze).
- Przygotowania: obozy, stamina, taktyka, XI + ławka 7.
- Nielegalny roster na mecz = walkower.

---

## 11. Wpływ na stan gry (podsumowanie)

```text
Staff growth/retire → ★ sztabu / luki w slotach
Awards              → historia, morale
Retirements         → roster −, cap +, możliwe <20; czas na BR do tyg.1
Lottery             → picki 1–10 (+ 11–30)
Scout Report        → snapshot wiedzy + assign Combine
Draft Combine       → combineScore, med flags, bonus scout
Mock Draft finalny  → sort UI + estymowane sloty scouta
Draft               → roster +, rookie contracts (okno wymian już od tyg.44)
  + generacja N+1   → 120 prospectów + mock wstępny
Extensions          → Bird / staff / else → FA
FA open             → podpisy 10h/dzień, skauting ciągły → tyg. 1
```
