# Offseason — reguły eventów

## 1. Zakres i kolejność

Szczegóły w `game_calendar.md`.

---

## 2. StaffGrowth

### Cel

Rozwój sztabu między sezonami. Mechanizm służy do odzwierciedlenia długoterminowego postępu, regresu, awansów i spadków jakości poszczególnych ról w sztabie.

### Zasady ogólne

- Każdy członek sztabu może zmienić swoje atrybuty po zakończonym sezonie.
- Zmiany są zależne od wieku (szczegóły w `staff.md`).

### Progres

- szansa na ulepszenie o 0,5 gwiazdki atrybutów kluczowych dla danej roli
- rozwój atrybutów następuje oddzielnie (możliwy wzrost kilku atrybutów)
- szansa na rozwój zależna od wieku (szczegóły poniżej)

### Regres

- szansa na regres o 0,5 gwiazdki atrybutów kluczowych dla danej roli
- regres atrybutów następuje oddzielnie (możliwy wzrost kilku atrybutów)
- szansa na regres zależna od wieku (szczegóły poniżej)

### Tabela szans na progres/regres atrybutu

| Wiek  | Szansa na wzrost | Szansa na brak zmian | Szansa na regres |
| ----- | ---------------- | -------------------- | ---------------- |
| 35–44 | 30%              | 65%                  | 5%               |
| 45-54 | 15%              | 60%                  | 15%              |
| 55–59 | 5%               | 65%                  | 30%              |
| 60+   | 0%               | 20%                  | 80%              |

### Przebieg

1. Robiony jest snapshot obecnych atrybutów.
2. System liczy StaffGrowth dla każdego członka sztabu.
3. Wynik wpływa na atrybuty.

---

## 3. Awards

### Cel

Przyznanie nagród indywidualnych i zespołowych za zakończony sezon.

### Progi minutowe

`possibleMinutes` = 58 × 90 = **5220** (sezon regularny). Progi liczą tylko **minuty sezonu regularnego**, o ile nie zaznaczono inaczej.

| Nagroda | Próg minut (regular) | Uwagi |
| ------- | -------------------- | ----- |
| **MVP** | ≥ **40%** (~≥ 2088 min) | poniżej progu: wykluczenie |
| **ROTY** | bez progu (ale mniej minut ciężej) | klasa draftowa roku N−1 |
| **DPOY** | ≥ **40%** | wykluczenie poniżej progu |
| **Król strzelców** | - | brak progu minut |
| **Król asyst** | - | brak progu minut |
| **Najlepszy BR** | ≥ **40%** jako `Position.gk` | minuty tylko w bramce; możliwy brak laureata |
| **Team of the Season** | ≥ **40%** na danym slocie | osobno per slot 4-3-3 |
| **Coach of the Year** | — | brak progu minut |

Progi i wagi — do strojenia w kodzie; ten dokument jest kanonem reguł.

### Kategorie i formuły

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

`ΔwinsVsProjected` = faktyczne zwycięstwa − `expectedWins`; `placeVsPreseasonSeed` = `expectedRank` − pozycja końcowa. Obie metryki z `team_management.md`.

Dla AI i gracza ta sama metryka (`staff.md` — Head Coach).

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

**Brak laureata:** liga nie wymaga minimalnej liczby bramkarzy w rosterze (`squad_management.md`), więc teoretycznie żaden zawodnik może nie osiągnąć progu 40% minut jako `Position.gk`. W takim wypadku nagroda **nie jest przyznawana** — kategoria pokazuje „brak laureata", a `seasonAwards` zapisuje `null`.

Scenariusz jest skrajnie nieprawdopodobny: pula generowanych zawodników i prospektów zawsze zawiera bramkarzy (`data_generation.md`), a AI zawsze utrzymuje co najmniej jednego GK i zawsze wystawia go w bramce (`AI_behaviour.md`). Reguła istnieje wyłącznie jako zabezpieczenie przed błędem walidacji, nie jako realna ścieżka rozgrywki.

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
2. Jeśli w danej kategorii **nikt nie spełnia progu minut**, nagroda nie jest przyznawana (`null` w `seasonAwards`, UI pokazuje „brak laureata"). Dotyczy wszystkich kategorii z progiem, w tym pojedynczych slotów Team of the Season.
3. UI: podium per kategoria + XI sezonu.
4. Zapis `seasonAwards`.
5. Lekki wpływ na atmosferę / morale — `team_management.md`.
6. Wiadomość z czerwoną flagą (domyślnie ważna) — `messages.md`.

Sixth Man / Impact Sub: poza zakresem — `Może_kiedyś_do_dodania.md`.

---

## 4. Retirements

### Cel

Zawodnicy kończą karierę; schodzą z rosterów przed draftem i FA.

### Model: tabela prawdopodobieństwa (wiek 33+)

Roll **raz na zawodnika** na koniec sezonu (event Retirements). Bazowa szansa zależy od wieku ukończonego w tym sezonie:

| Wiek | P_base (emerytura) |
| ---- | -----------------: |
| ≤ 32 | **0%** |
| 33 | 3% |
| 34 | 8% |
| 35 | 18% |
| 36 | 32% |
| 37 | 55% |
| 38 | 78% |
| 39+ | 100% |

### Skutki

1. Usunięcie z `roster`; kontrakt wygasa bez FA.
2. Roster może wyjść poza **20–30** (poniżej 20; więcej niż 30 niemożliwe) — **jedyna** droga poza limit to emerytura. Przy nielegalnym rosterze w dniu meczu: **walkower**.
3. Zwolnienie cap space.

AI nie blokuje emerytury — decyzja zawodnika (roll).

---

## 5. Lottery

Szczegóły w `draft.md`.

---

## 6. Scout Report

### Cel

1. Pokazanie listy obserwowanych prospectów z **całą wiedzą** zebraną przez scouta od startu skautingu.
2. **Przypisanie scouta** do obserwacji wybranych prospectów na **Draft Combine**.

### Przebieg

1. UI: lista watchlist z danymi zebranymi przez scouta.
2. Gracz (i AI) wybiera cele Combine: limit ≈ **½ Coverage** (zaokrąglenie w dół).

Nieprzypisany prospect i tak uczestniczy w Combine, ale klub **nie dostaje** dodatkowych informacji.

---

## 7. Draft Combine 

### Cel

1. **Możliwość zaprezentowania swoich umiejętności przez prospecty** — cała klasa (120).

### Testy

Prospecty z `combineAssignments` ujawniają swoją optymalną rolę na boisku.

### Po Combine

- Scout aktualizuje swoje dane w watchlist na temat prospectów

---

## 8. Mock Draft — finalny

Szczegóły w `draft.md`.

---

## 9. Draft 

### Cel

Szczegóły w `draft.md`.

---

## 10. Contract extensions 

Szczegóły w `contracts.md`.

---

## 11. Free agency open 

Szczegóły w `contracts.md`.

---
