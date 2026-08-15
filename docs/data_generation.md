# Generowanie danych

## Liga (`generateLeague`)

Punkt wejścia — tworzy pełny `LeagueState` zawierający:
- 30 drużyn (15 Europa / 15 reszta świata) podzielonych na konferencje `europe` i `restOfTheWorld`
- Tabele (`ConferenceStandings`) z zerowym stanem dla każdej konferencji
- Następny draft (`DraftState` — rok + klasa draftowa)
- Oznaczenie drużyny gracza (`playerTeamId`)

Parametry: `year` (domyślnie 2026), opcjonalny `playerTeamId`, opcjonalny `seed` do RNG.

## Drużyny (`_generateTeam`)

Każda drużyna zawiera:
- Identyfikator, nazwę, miasto, konferencję
- Roster (patrz niżej)
- Finanse (`TeamFinance.totalPayroll` = suma pensji z rosteru)
- Lineup (pierwszych 11 graczy) i ławkę (kolejnych 7)
- Pula picków draftowych (7 roczników × 3 rundy = 21 picków)
- Konfiguracja AI (`ManagerProfile`) — losowy profil, `null` dla drużyny gracza

## Rosters

- Losowa formacja z `Formation.values`

## Zawodnicy (`_generatePlayer`)

Każdy gracz posiada:

### Podstawowe dane
- Imię i nazwisko — z puli nazw per narodowość
- Pozycja, narodowość (losowa z enum)
- Wiek: 19–35
- Wzrost: zależny od pozycji (GK 175-200, CB 175-200, ST 170-195, CDM 170-195, reszta 160-190 cm)
- Osobowość (`PlayerPersonality`) — losowa
- Optymalna rola: losowa dla danej pozycji

### Wagi atrybutów pozycji

Wagi atrybutów dla każdej pozycji są zdefiniowane w `balance_config.dart` w `_defaultOutfieldOverallWeights`. Na ich podstawie ma być  obliczany range OVR pojedynczych atrybutów.

```text
0.05 -> X-18 --- X-13
0.08 -> X-8 --- X-5
0.10 -> X-6 --- X-3
0.12 -> X-4 --- X-2
0.14 -> X-3 --- X
0.15 -> X-2 --- X
0.18 -> X --- X+1
0.20 -> X-1 --- X+1
0.25 -> X+2 --- X+3
0.28 -> X+3 --- X+4
0.30 -> X+3 --- X+4
0.35 -> X+4 --- X+6
0.40 -> X+3 --- X+5
```

### Generowanie OVR

OVR atrybutów jest generowany za pomocą funkcji mapującej oczekiwany OVR X oraz wagi atrybutów dla każdej pozycji. Np. X = 80, position = CB, wagi:
    pace: 0.10,
    shooting: 0.05,
    passing: 0.15,
    dribbling: 0.05,
    defending: 0.40,
    physicality: 0.25,

Daje expected value X + 0,08 OVR

### Bramkarze

W `_defaultOutfieldOverallWeights` nie ma wag dla bramkarza - ma on wagę 1/6 dla każdego atrybutu. Generowanie atrybutu dla bramkarza ma więc inne zasady - dla każdego atrybutu liczona jest wartość z zakresu **X-2 --- X+2**.

### Potencjał

Potencjał gracza jest generowany na podstawie OVR i wieku. 

| Wiek \\ OVR | 50–59     | 60–69     | 70–77     | 78–83      | 84–89     | 90–95      |
| ---------- | ---------- | --------- | --------- | ---------- | --------- | ---------- |
| 18–22      | 2.0–3.0 ★ | 3.5–4.5 ★ | 3.0–4.0 ★ | 3.5–4.5 ★ | 4.5–5.0 ★ | 5.0 ★     |
| 23–26      | 2.0–2.5 ★ | 3.0–4.0 ★ | 3.0–3.5 ★ | 3.5–4.0 ★ | 4.5–5.0 ★ | 5.0 ★     |
| 27–32      | 1.0–2.0 ★ | 2.0–3.5 ★ | 2.5–3.0 ★ | 3.0–4.0 ★ | 4.5 ★     | 5.0 ★     |
| 33–40      | 0.5–1.5 ★ | 1.5–2.5 ★ | 2.5–3.0 ★ | 3.0–3.5 ★ | 4.5 ★     | 5.0 ★     |

### Kontrakt
- Pensja: 
```text
salary = minSalary + (maxSalary − minSalary) × (((OVR-50)*2) / 100)^3
minSalary = salary_cap.md
maxSalary = salary_cap.md
OVR = overall zawodnika
```
- Lata: 1–4
- Bird rights: 0

### Stan (`PlayerState`)
- Stamina: 100
- Forma: 3-8
- Rola: domyślna dla pozycji
- Sezony w drużynie: 0

### Ukryte (`PlayerHidden`)
- Injury prone: 1–10
- Determination: 1–10
- Overall progress: wiek ≤26 → 40-89, starszy → 0-29 (clamp 0–99)
- Growth rate: 0.7–1.5 (clamp 0.0–2.0)
- Development outcome: zależy od determination (rollDevelopmentOutcome)

### Point Value

Obliczana od razu po wygenerowaniu całego zawodnika.

## Generowanie zawodników na początku save'a

- Pozycje wynikają z layoutu formacji (×2) + 4 (GK, CB, CM, ST) (formacja generowana dla rosteru)

| Liczba graczy | OVR | Wiek  |
| ------------- | --- | ----- |
| 2x            | 85  | 27–30 |
| 1x            | 84  | 32–35 |
| 2x            | 82  | 23–26 |
| 1x            | 81  | 23–24 |
| 2x            | 80  | 27-32 |
| 2x            | 79  | 27–32 |
| 1x            | 79  | 23–26 |
| 1x            | 79  | 33–40 |
| 3x            | 77  | 27–32 |
| 2x            | 77  | 23–26 |
| 1x            | 77  | 33–40 |
| 2x            | 75  | 18–22 |
| 1x            | 73  | 27–32 |
| 1x            | 72  | 33–40 |
| 1x            | 70  | 38–40 |
| 1x            | 68  | 18–22 |
| 1x            | 66  | 18–22 |
| 1x            | 63  | 18–22 |

## Prospects / Klasa draftowa (`generateDraftClass`)

- Domyślnie 120 prospektów na rocznik
- Pozycja: losowa
- Atrybuty: identyczna formuła jak u zawodnikó (na podstawie wag pozycji i OVR)
- Wiek: 18–20
- Wzrost: jak u graczy (zależny od pozycji)
- Injury prone: 1–10
- Determination: 1–10
- Osobowość: losowa
- Optymalna rola: losowa dla danej pozycji

## Potencjał i OVR

| Liczba graczy | OVR   | Potencjał (★) |
| ------------- | ----- | ------------- |
| 3x            | 77–79 | 4.0–5.0       |
| 8x            | 74–76 | 3.5–4.5       |
| 12x           | 70–73 | 3.5–4.0       |
| 10x           | 65–75 | 3.0–4.5       |
| 20x           | 66–69 | 3.0–3.5       |
| 20x           | 62–65 | 2.5–3.0       |
| 20x           | 58–61 | 2.0–2.5       |
| 27x           | 58–79 | 2.0–5.0       |

## Staff 

Kanoniczne nazwy 6 ról (`StaffRole`) — zgodnie z `staff.md`:

| Rola | Kod enum | Atrybuty |
| ---- | -------- | -------- |
| Trener główny | `headCoach` | Tactics, Motivation |
| Trener rozwojowy | `developmentCoach` | Development, Mentoring |
| Scout | `scout` | Coverage, Evaluation |
| Fizjo | `physio` | Rehabilitation, Regeneration |
| Lekarz | `doctor` | Prevention, Care |
| CFO | `cfo` | Negotiation |

> Enum w kodzie musi używać dokładnie tych nazw. Warianty `youthCoach` oraz `regenaration` są nieaktualne.

### Generowanie po staffGrowth

Po staffGrowth defaultowo jest generowanych **10-20** członków staffu według poniższych zasad.

- Wiek: 35–50
- Gwiazdki atrybutów: 
| Gwiazdki  | Prawdopodobieństwo | Komentarz                          |
| --------- | ------------------ | ---------------------------------- |
| 0.5 ★     | 10%                | Bardzo słabi członkowie sztabu     |
| 1.0 ★     | 10%                | Słaby poziom                       |
| 1.5 ★     | 10%                | Niski poziom                       |
| 2.0 ★     | 15%                | Poniżej średniej                   |
| 2.5 ★     | 20%                | Średni-dolny poziom                |
| 3.0 ★     | 15%                | Średni poziom                      |
| 3.5 ★     | 10%                | Dobry staff                        |
| 4.0 ★     | 6%                 | Bardzo dobry staff                 |
| 4.5 ★     | 3%                 | Elitarni kandydaci                 |
| 5.0 ★     | 1%                 | Absolutny top                      |

### Generowanie na początku save'a

Każdy zespół otrzymuje staff na każdą pozycję. Dodatkowo generowanych jest 15 członkw sztabu na każdą pozycję jako wolnych agentów (generowanie według zasad `Generowanie po staffGrowth`).

- Wiek: 35–50
- Gwiazdki atrybutów: każdy zespół dostaje 3x 2★ (długość kontraktu 1 rok, pensja 750000), 1x 2,5★ (długość kontraktu 1 rok, pensja 1000000), 1x 3★ (długość kontraktu 2 rok, pensja 1500000), 1x 3,5★ (długość kontraktu 2 rok, pensja 2000000). Role do których przypisywani są konkretni członkowie są losowe.


## Draft Picks (`_generateOwnedPicks`)

- Każda drużyna startuje z 21 pickami: lata `seasonYear+1` do `seasonYear+7`, rundy 1–3
- `pickNumber` = `null` do czasu loterii (`SeasonService.runLottery`)
- Trade value przeliczana przy generacji (`recalculateTradeValue(currentYear)`)

## Seed Generation

### Game schedule
_(do uzupełnienia — harmonogram meczów generowany poza `SeedDataGenerator`)_

### Imiona i nazwiska graczy i staffu
- Pula imion i nazwisk per narodowość (`namePools[nationality]`)
- Losowe łączenie firstName + lastName
