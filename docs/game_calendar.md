# Kalendarz sezonu

Dokument opisuje **roczny cykl rozgrywkowy** ligi (30 drużyn, 58 meczów regularnych).

**Oś czasu:** numer tygodnia liczony od **startu sezonu regularnego** (tydzień 1 = poniedziałek–niedziela pierwszego tygodnia rozgrywek).  
Konkretny rok kalendarzowy (sierpień → sierpień) wynika z kotwicy startu; **fazy i eventy offseason są zawsze pod tymi samymi numerami tygodni**.

Kotwica startu: **pierwszy pełny tydzień sierpnia** (pon.–niedz. w całości w sierpniu) = tydzień **1**.

Numery tygodni są **ciągłe**: po niedzieli tyg. *N* następuje poniedziałek tyg. *N+1* (brak „dziur” poza jawnym tygodniem przerwy).

Day-to-day i inbox: `messages.md`. Negocjacje kontraktów: `contracts.md`.

---

## Roczny przegląd (tyg. 1 → 1 następnego sezonu)

```
Tyg. 1 ──────────────────────────── Tyg. 29
│◄────── Sezon regularny (29 tyg.) ──────►│
                                          ▼
Tyg. 30 ──► Przerwa przed play-in
Tyg. 31 ──► Play-in
Tyg. 32–43 ──► Playoff (12 tyg.)
           └──► Tyg. 44: Awards (pon), Staff growth/retire (wt),
                    Retirements (śr), Lottery (pt)
Tyg. 44–45 ──► Awards, retirements, lottery, scout, combine, mock
              (okno wymian już otwarte od końca playoff)
Tyg. 46     ──► Draft + mock wstępny klasy N+1 + przedłużenia
Tyg. 47 …   ──► Free agency + skauting ciągły + przygotowania
                → Tyg. 1 następnego sezonu
```

| Faza | Tygodnie sezonu | Mecze max / tydz. |
| ---- | --------------- | ----------------: |
| Sezon regularny | **1–29** | 2 |
| Przerwa przed play-in | **30** | — |
| Play-in | **31** | 2 sloty |
| Playoff R1 (ćwierćfinały konf.) | **32–34** | 2 |
| Playoff R2 (półfinały konf.) | **35–37** | 2 |
| Finały konferencji | **38–40** | 2 |
| Finał ligi | **41–43** | 2 |
| Offseason  | **44** → do tyg. 1 kolejnego sezonu | — |

Od końca finału (koniec tyg. **43**) do startu kolejnego sezonu jest **~9 tygodni** (44–… + reszta lata) — wystarcza na draft, FA i przedłużenia.

---

## Sezon regularny (tyg. 1–29)

**Start:** poniedziałek tygodnia **1**.  
**Koniec:** niedziela tygodnia **29**.

**Rytm meczowy:** 2 terminy na tydzień.

| Slot | Dni (typowo) | Uwagi |
| ---- | ------------ | ----- |
| A | środa / czwartek | środek tygodnia |
| B | sobota / niedziela | weekend |

```
29 tygodni × 2 mecze = 58 meczów / drużynę
```

To dokładnie odpowiada **double round robin** (30 drużyn, każdy z każdym 2×).

### Przerwa przed play-in (tyg. 30)

Po niedzieli tyg. **29** następuje poniedziałek tyg. **30** — cały ten tydzień to **przerwa** (bez meczów ligowych): regeneracja, domknięcie tabeli, przygotowanie drabinki play-in.

Play-in zaczyna się poniedziałkiem tygodnia **31**.

### Okno wymian i trade deadline

| Event | Kiedy |
| ----- | ----- |
| **Otwarcie okna** | po finale playoff (od poniedziałku tyg. **44**) — `trades.md` |
| **Trade deadline** | **poniedziałek tygodnia 23** sezonu regularnego |

Po deadline zabronione są nowe transakcje do **końca kolejnego playoff**. Okno otwiera się znowu po finale (poniedziałek tyg. 44).

---

## Play-off

### Play-in (tyg. 31)

Jeden tydzień; obie konferencje równolegle.

| Dzień | Event |
| ----- | ----- |
| **Środa** tyg. 31 | Mecz 1: seed 7 vs 8 |
| **Środa** tyg. 31 | Mecz 2: seed 9 vs 10 |
| **Sobota** tyg. 31 | Mecz 3: przegrany (7/8) vs wygrany (9/10) |

→ 2 awansujących na konferencję → **8 drużyn** w drabince pucharowej.

### Drabinka BO5 (tyg. 32–43)

Format: **best-of-5** (do 3 wygranych). Przy 2 slotach/tydz. maksymalnie **4 mecze/tydz.** → seria BO5 mieści się w **2–3 tygodniach** (wyżej rozstawiony zaczyna u siebie; format 1-2-2).

| Runda | Tygodnie | Serii równolegle |
| ----- | -------- | ---------------- |
| Ćwierćfinały konferencji | **32–34** | 4 × 2 konferencje |
| Półfinały konferencji | **35–37** | 2 × 2 |
| Finały konferencji | **38–40** | 1 × 2 |
| Finał ligi | **41–43** | 1 |

**Koniec play-off:** niedziela tygodnia **43**.

> Trzy tygodnie na finał ligi to **świadomy bufor** — realnie seria BO5 często kończy się w 2 tygodnie; trzeci tydzień absorbuje dogrywki i daje margines na UI/symulację.

Po finale rozpoczyna się offseason: Awards odbywa się w poniedziałek tygodnia 44,
a roll wzrostu i emerytury sztabu w następny dzień, wtorek tygodnia 44 — `staff.md`.

---

## Offseason

| Okres | Tygodnie | Wydarzenia |
| ----- | -------- | ---------- |
| Przerwa po play-off | **44–45** | otwarcie okna wymian, awards, retirements, lottery, scout report, combine, mock finalny |
| Draft + przedłużenia | **46** poniedziałek | 3 rundy draftu; **generacja klasy N+1 + mock wstępny** |
| Przedłużenia kontraktów | **46** wtorek - niedziela | Contract extension `contracts.md` |
| Free agency | od **poniedziałku tyg. 47** | FA, RFA match|
| Przygotowania | tyg. **47** → tyg. **1** kolejnego sezonu | wymiany, domykanie rosteru |

Szczegóły reguł eventów: **`offseason.md`**.

---

## Exact schedule — offseason przed draftem (tyg. 44–45)

| Event | Kiedy | Opis |
| ----- | ----- | ---- |
| **Awards** | **poniedziałek tygodnia 44** | Nagrody sezonu (MVP, ROTY, DPOY, Coach, królowie, BR, Team of the Season). **Od tego dnia (po finale) okno wymian jest otwarte.** |
| **Staff growth / retire** | **wtorek tygodnia 44** | Upgrade ★ sztabu (35–45) i emerytury sztabu (55–60) — `staff.md` |
| **Retirements** | **środa tygodnia 44** | Decyzje o emeryturze (tabela P dla 33+). Zawodnicy schodzą z rosteru; limity **20–30** (`squad_management.md`). |
| **Lottery** | **piątek tygodnia 44** | Loteria draftowa dla **10** najsłabszych drużyn — picki **1–10** 1. rundy (`draft.md`). Picki **11–30** według tabeli. |
| **Scout Report** | **poniedziałek tygodnia 45** | Podsumowanie wiedzy scouta o obserwowanych prospectach + **assign na Draft Combine**. |
| **Draft Combine** | **środa tygodnia 45** | Mecz pokazowy (2 najlepsi na pozycji) + testy fizyczne/medyczne całej klasy. |
| **Mock Draft (finalny)** | **piątek tygodnia 45** | Finalny mock (Combine + rok rozwoju); sort UI listy prospectów. Scout dopina estymowane sloty. |

Szczegóły: **`offseason.md`**.

---

## Exact schedule — tydzień 46 (draft + przedłużenia)

| Event | Kiedy | Opis |
| ----- | ----- | ---- |
| **Draft** | **poniedziałek tygodnia 46** | `draft.md` |
| **Contract extensions** | **wtorek–niedziela tygodnia 46** | `contracts.md` |
| **Free agency open** | **poniedziałek tygodnia 47** | `contracts.md` |

Szczegóły: **`offseason.md`**.

---

## Pełna mapa tygodni (odniesienie implementacyjne)

| # | Faza |
| - | ---- |
| **1–29** | Sezon regularny |
| **30** | Przerwa przed play-in |
| **31** | Play-in |
| **32–34** | Playoff — runda 1 |
| **35–37** | Playoff — runda 2 |
| **38–40** | Finały konferencji |
| **41–43** | Finał ligi |
| **44** | Awards (pon), StaffGrowth/retire (wt), Retirements (śr), Lottery (pt) |
| **45** | Scout Report (pon), Draft Combine (śr), Mock Draft finalny (pt) |
| **46** | Draft (pon) + mock wstępny N+1 + przedłużenia (wt–niedz) |
| **47+** | Free agency + skauting ciągły + przygotowania |
| **1** (kolejny sezon) | Start sezonu regularnego |

### Kluczowe eventy (checklist silnika)

| Event | Moment |
| ----- | ------ |
| Start sezonu | Poniedziałek tyg. **1** |
| Trade deadline | Poniedziałek tyg. **23** |
| Koniec regularnego | Niedziela tyg. **29** |
| Przerwa przed play-in | Tyg. **30** |
| Play-in | Tyg. **31** (śr ×2, sob) |
| Koniec playoff | Niedziela tyg. **43** |
| Otwarcie okna wymian | Poniedziałek tyg. **44** (po finale) |
| Awards | Poniedziałek tyg. **44** |
| Staff growth / retire | Wtorek tyg. **44** |
| Retirements | Środa tyg. **44** |
| Lottery | Piątek tyg. **44** |
| Scout Report | Poniedziałek tyg. **45** |
| Draft Combine | Środa tyg. **45** |
| Mock Draft (finalny) | Piątek tyg. **45** |
| Draft + generacja klasy N+1 + mock wstępny | Poniedziałek tyg. **46** |
| Extensions window | Wt–niedz tyg. **46** |
| FA open + skauting ciągły | Poniedziałek tyg. **47** |
| Start kolejnego sezonu | Poniedziałek tyg. **1** (nowy cykl) |

---

## Reguły dopasowania do silnika gry

W kodzie (`ScheduleGenerator` / day-to-day):

- **58 meczów** = wynik 29 × 2 w sezonie regularnym (niezależnie od dat wall-clock).
- Numer tygodnia sezonu jest **kanoniczny** dla eventów (nie polegaj na „14 czerwca”).
- **Fazy** (`SeasonPhase` w `enums.dart`): `preseason` → `regular` → `playIn` → `playoff` → `offseason`.
- **Preseason:** faza techniczna przed poniedziałkiem tyg. **1** — **nic się nie dzieje** (brak meczów, eventów, skautingu, FA). Służy tylko do spójności enum / UI „przed startem”.
- Symulacja dzień-po-dniu + pauza na czerwone flagi inboxa — `messages.md`.

---

## Uwagi projektowe

1. **Kontuzje i zmęczenie** — 2 mecze/tydz. przez 29 tyg. to intensywny kalendarz; rotacja i stamina mają wysoką wagę (`player_management.md`, `squad_management.md`).
2. **Trade window** — otwarte od początku offseason (tyg. **44**) do trade deadline (tyg. **23**); zamknięte od deadline do końca kolejnego playoff — `trades.md`.
3. Przy przesunięciu kotwicy sierpnia (rok kalendarzowy) **numery tygodni i dni tygodnia eventów pozostają bez zmian**.
4. Klasy draftowe żyją ~rok: generacja po drafcie → skauting od FA → Scout Report / Combine / mock finalny → draft.
