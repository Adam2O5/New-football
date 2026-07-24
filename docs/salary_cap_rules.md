### Podstawy salary cap

- Liga stosuje **ograniczenie pensji** (salary cap) — łączna roczna pensja wszystkich zawodników w składzie nie może bez kontroli przekraczać limitu.
- Domyślny limit ligi: **300 000 000 €** na drużynę (`salaryCap`).
- Skala jest **wyższa niż klasyczny wzorzec NBA**, bo roster liczy **20–30** zawodników (NBA ~15) — cap ≈ **2×** poprzedniego modelu 150M, z zachowaniem proporcji apronów.
- **Payroll** to suma pensji wszystkich zawodników w składzie; aktualizowany automatycznie po każdej zmianie rosteru.
- **Cap space** = `salaryCap − totalPayroll`. Dodatni cap space oznacza wolne środki; ujemny — przekroczenie limitu.

### Aktualizacja limitu (prawa telewizyjne)

- Limit pensji jest **uzgadniany co 5–7 lat** przy podpisaniu nowej umowy na prawa telewizyjne ligi.
- Dokładny rok skoku jest **znany z góry** w momencie podpisania umowy TV (w grze: widoczny w kalendarzu / ekranie finansów jako „następny reset capu: sezon X”).
- Wzrost capu zależy od wartości kontraktu medialnego.
- Po aktualizacji capu przeliczane są wszystkie progi apronów (patrz niżej) — istniejące kontrakty pozostają bez zmian do wygaśnięcia.

### Trzy pułapy finansowe

Liga operuje na poziomach payrollu. Im wyżej, tym mniejsza elastyczność w podpisach i wymianach.

| Pułap | Próg (przy cap 300M) | Znaczenie |
| ----- | -------------------- | --------- |
| **Poniżej cap** | payroll ≤ **300M** | Pełna elastyczność — podpisy w ramach cap space |
| **1st apron** | **300M** < payroll ≤ **340M** | Soft cap — wyjątki OK, ograniczone wymiany (`trade_rules.md`) |
| **Między apronami** | **340M** < payroll ≤ **370M** | Brak agregacji w wymianach; wyższy podatek |
| **2nd apron** | payroll > **370M** | Twardy reżim — brak MLE, brak netto wzrostu w trade, najwyższy podatek |

Progi (proporcje jak w starym modelu 150 / 170 / 185, tu **×2**):

| Próg | Kwota | vs cap |
| ---- | ----- | ------ |
| Salary cap | **300 000 000 €** | 100% |
| 1st apron | **340 000 000 €** | ≈ +13,3% |
| 2nd apron | **370 000 000 €** | ≈ +23,3% |

> Przy każdej aktualizacji TV aprony skalują się **tymi samymi procentami** względem nowego limitu.

### Walidacja składu (hard cap + wyjątki)

Silnik gry (`SalaryCapValidator`) sprawdza, czy drużyna jest **legalna** finansowo:

1. Jeśli `payroll ≤ salaryCap` → skład **OK**.
2. Jeśli `payroll > salaryCap` → nadwyżka musi być pokryta **aktywnymi wyjątkami** (`activeExceptions`).
3. Jeśli nadwyżka przekracza sumę dostępnych wyjątków → skład **nieważny** (komunikat: przekroczenie hard cap).

W UI (ekran Finanse) status wyświetlany jest jako „OK” lub „Przekroczenie cap”.

### Wyjątki cap (exceptions)

Wyjątki pozwalają legalnie przekroczyć salary cap w określonych sytuacjach. Każdy wyjątek ma typ, kwotę (`amountRemaining`) i opcjonalnie przypisanego zawodnika.

| Typ | Domyślna kwota | Zasady |
| --- | -------------- | ------ |
| **Bird rights** | indywidualna | Przedłużenie własnego zawodnika powyżej cap; przypisany do `playerId` |
| **Mid-level (MLE)** | **20 400 000 €** | Jednorazowy podpis wolnego agenta powyżej cap; **1× na sezon FA** (≈ 6,8% capu) |
| **Rookie scale** | wg picka | Automatyczny przy draftcie; pensja z tabeli rookie scale |

#### Bird rights

- Aktywne, gdy zawodnik ma flagę `hasBirdRights` **lub** spędził **≥ 3 sezonów** w drużynie (`seasonsWithTeam`).
- Pozwalają przedłużyć kontrakt powyżej cap, jeśli drużyna posiada wyjątek Bird rights przypisany do tego zawodnika.
- Po wymianie: `seasonsWithTeam` = **0**, `hasBirdRights` = **false** — nowy klub **odbudowuje** Bird od zera (`trade_rules.md`).

#### Mid-level exception (MLE)

- Domyślna kwota: **20 400 000 €** (`midLevelExceptionAmount`).
- Dostępna **raz na cykl FA** (`midLevelExceptionAvailable`).
- **Reset:** `midLevelExceptionAvailable = true` przy **FA open (poniedziałek tyg. 47)** — `game_calendar.md` / `offseason.md`.
- Po użyciu flaga ustawiana na `false` — nie można podpisać drugiego zawodnika tym samym wyjątkiem do kolejnego FA open.
- **Niedostępna** dla drużyn powyżej **2nd apron**.
- Pensja podpisywanego zawodnika nie może przekroczyć kwoty MLE.

#### Rookie scale

- Automatyczny kontrakt dla wybranych w draftcie (szczegóły w `draft_rules.md`).
- **2 lata**, pensja z tabeli scale — nie wymaga wolnego cap space.
- Flagi kontraktu: `isRookieScale: true`, `rookiePickSlot` = numer picka.
- `baseScale` = **8 000 000 €**; clamp pensji rookie: **500 000 – 8 000 000 €**.
- Formuła: `baseScale / (1 + pickSlot × 0,08)`.

### Restricted Free Agency (RFA) — prawo match (wzorzec NBA)

Po wygaśnięciu **rookie scale (2 lata)** zawodnik wchodzi w **RFA**, o ile dotychczasowy klub złoży **Qualifying Offer (QO)** w oknie przedłużeń (tyg. 46) lub na starcie FA.

#### Qualifying Offer

- Klub musi złożyć QO (pensja ≥ ostatnia pensja rookie scale × **1,25**, min. **1 000 000 €**, max jak limity ligi) — inaczej zawodnik staje się **UFA**.
- QO wiąże klub: jeśli zawodnik akceptuje QO bez oferty zewnętrznej → 1-roczny kontrakt na kwotę QO.

#### Offer sheet (inna drużyna)

1. Inny klub składa **offer sheet**: pensja + lata (jak zwykła oferta FA), legalna względem własnego cap / MLE / apron.
2. Dotychczasowy klub ma **prawo match** (Right of First Refusal): **48 godzin** zegara gry (w oknie 10h/dzień: do końca **następnego pełnego dnia** negocjacji, min. 2 sloty godzinowe jeśli FA trwa).
3. **Match:** klub dotychczasowy podpisuje **identyczne** warunki (ta sama pensja roczna i ta sama długość). Zawodnik zostaje; Bird / staż kontynuowane u dotychczasowego klubu.
4. **Brak match:** zawodnik przechodzi do klubu z offer sheet; dotychczasowy klub **nie** dostaje rekompensaty draftowej (jak współczesne NBA RFA).
5. W trakcie okna match zawodnik nie może podpisać innej oferty.

#### RFA vs UFA (skrót)

| Status | Warunek | Skutek |
| ------ | ------- | ------ |
| **RFA** | po rookiescale + ważny QO | offer sheet + prawo match dotychczasowego klubu |
| **UFA** | brak QO / wygasły weteran bez Bird extension / niedraftowany FA | wolny rynek bez match |

Negocjacje godzinowe: `contract_signing.md`. AI: `AI_behaviour.md`.

### Kontrakty zawodników

Każdy zawodnik ma kontrakt z polami:

| Pole | Znaczenie |
| ---- | --------- |
| `salary` | Roczna pensja (€) |
| `yearsRemaining` | Lata do wygaśnięcia |
| `hasBirdRights` | Czy klub ma prawo przedłużenia powyżej cap |
| `isRookieScale` | Kontrakt rookie scale |
| `rookiePickSlot` | Numer picka (dla rookie scale) |

**Zakres pensji w lidze** (wygenerowani zawodnicy):

- Minimum: **500 000 €**
- Maximum: **80 000 000 €** (≈ 26,7% capu)
- Formuła startowa: `500 000 + overall × 400 000 + losowa wariancja` (skala spójna z capem 300M).

### Podpisywanie zawodników

- **Poniżej cap:** nowy kontrakt do wysokości dostępnego cap space — bez wyjątków.
- **Powyżej cap:** wymagany odpowiedni wyjątek (MLE, Bird rights, rookie scale).
- Metoda `canSignPlayer(salary, exception)` sprawdza, czy pensja mieści się w cap space lub w kwocie wyjątku.

Kolejność preferencji przy budowaniu składu:

1. Cap space (najtańsza opcja).
2. Rookie scale (draft).
3. Bird rights (własni weterani).
4. MLE (wolni agenci — jeden na cykl FA).

### Podatek luxury (apron tax)

Drużyny powyżej salary cap płacą **dodatkowy podatek** od nadwyżki pensji:

| Strefa payrollu | Podatek od nadwyżki ponad cap |
| --------------- | ----------------------------- |
| Powyżej cap, do **1st apron** (≤ 340M) | **1,75 €** za każde 1 € nad cap |
| Powyżej 1st apron, do **2nd apron** (≤ 370M) | **2,25 €** za każde 1 € nad cap |
| Powyżej **2nd apron** (> 370M) | **3,00 €** za każde 1 € nad cap |

- Podatek **nie** zmniejsza cap space — to koszt z **budżetu operacyjnego** (`cashBalance`, poniżej).
- Drużyny poniżej cap nie płacą podatku.

### Budżet operacyjny klubu (`cashBalance`)

Osobny od salary cap i staff cap. Cap ogranicza **pensje zawodników**; budżet operacyjny to **gotówka klubu** na koszty sezonu.

#### Saldo startowe (nowa kariera)

- `cashBalance` ≈ **75 000 000 €** (± 15M zależnie od rynku / seedu).

#### Przychody (rozliczenie roczne — po finale / na starcie offseason)

| Źródło | Orientacja (do tuningu) |
| ------ | ----------------------- |
| Udział TV (baza, równy) | **+90 000 000 €** |
| Bonus TV / sukces | **0 … +45 000 000 €** (play-in → mistrz, schodkowo) |
| Bilety + sponsoring (uprośc.) | **+25 … +70 000 000 €** (frekwencja ∝ miejsce w tabeli, atmosfera, overall składu) |

#### Koszty (to samo rozliczenie + bieżące)

| Koszt | Reguła |
| ----- | ------ |
| Pensje zawodników | już w payroll — **nie** odejmować drugi raz z cash przy podpisie; cash obciążany **rocznym rozliczeniem** sumy payrollu sezonu (albo proporcjonalnie co miesiąc — v1: raz na rok w offseason) |
| Pensje sztabu | suma kontraktów staff (`staff_rules.md`) |
| Luxury tax | wg tabeli apron tax — **płatny z cash** |
| Koszty operacyjne (stałe) | **~18 000 000 €** / sezon (utrzymanie, biuro, logistyka) |

```text
cash' = cash
      + TV_base + TV_bonus + gateSponsor
      − playerPayrollYear − staffPayrollYear − luxuryTax − opsFixed
```

#### Skutki niskiego / ujemnego cash

| `cashBalance` | Skutek |
| ------------- | ------ |
| ≥ 20M | OK |
| 0 … 20M | Ostrzeżenie zarządu; lekki dren atmosfery |
| &lt; 0 | **Dług**: blokada przedłużeń staff powyżej rynku; AI unika; gracz może nadal honorować istniejące kontrakty zawodników; brak nowych hire staff elite; dodatkowy −atmosfera |

v1: brak bankructwa / wymuszonej sprzedaży — tylko presja i ograniczenia operacyjne. Kwoty do strojenia w kodzie (`BalanceConfig`).

### Wymiany a salary cap

Podstawowa walidacja wymiany (`TransferEngine`):

- Po wymianie **obie drużyny** muszą mieć legalny payroll (cap + wyjątki) **oraz** legalny roster (`squad_management.md`: 20–30; bez min. GK).
- Projekcja payrollu: `nowy payroll = stary payroll − wychodzący + przychodzący`.

Szczegółowe reguły dopasowania pensji (125% matching, agregacja, ograniczenia apronów): `trade_rules.md`.

### Ograniczenia przy pułapach (skrót)

| Poziom | Podpisy | Wymiany |
| ------ | ------- | ------- |
| Poniżej cap | Pełna elastyczność w cap space | Bez dopasowania pensji |
| Powyżej cap, poniżej 1st apron | Wyjątki (MLE, Bird, rookie) | Matching 125% + TPE; agregacja dozwolona |
| 1st apron – 2nd apron | MLE OK (jeśli nie 2nd) | Brak agregacji |
| Powyżej 2nd apron | Tylko obniżenie payrollu / brak MLE | Brak netto wzrostu pensji; brak MLE |

### Cykl sezonowy a finanse

| Okres | Co się dzieje |
| ----- | ------------- |
| Sezon regularny | Bieżący cap; trade deadline w tyg. 23 (`game_calendar.md`) |
| Po finale (offseason) | Rozliczenie przychodów / kosztów / tax → `cashBalance` |
| Draft (tyg. 46) | Rookie scale; payroll += pensje draftowanych |
| Przedłużenia (tyg. 46) | Bird; QO dla kończących rookiescale |
| Free agency (od tyg. 47) | **Reset MLE**; podpisy UFA/RFA; offer sheet + match |

### Po wygaśnięciu kontraktu

- Zawodnik bez kontraktu: **UFA** albo **RFA** (jeśli QO złożone).
- Klub traci wpis pensji z payrollu — cap space rośnie o zwolnioną kwotę.
- Bird rights wygasają, jeśli klub nie przedłuży w oknie przedłużeń.
- Rookie po 2 latach scale → RFA (z QO) lub UFA (bez QO).

### Wskazówki dla menedżera

- Utrzymuj **cap space** na offseason — MLE i Bird nie zastąpią dużego wolnego miejsca pod gwiazdę.
- Nie przekraczaj **2nd apron** bez planu — ogranicza wymiany; tax 3,00 €/€ drenuje `cashBalance`.
- Śledź `yearsRemaining` i QO — utrata RFA bez walki to zbędny prezent rynkowi.
- Rookie scale to najtańszy talent młody przy tight cap.
- Zachowanie AI: `AI_behaviour.md`.
