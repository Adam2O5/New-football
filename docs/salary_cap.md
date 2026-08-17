# Salary cap

## Podstawy salary cap

- Liga stosuje **ograniczenie pensji zawodników** (`salaryCap`) — łączna roczna pensja wszystkich zawodników w składzie nie może bez kontroli przekraczać limitu.
- Domyślny limit ligi: **350 000 000 €** na drużynę (`salaryCap`).
- **Payroll** to suma rocznych pensji wszystkich zawodników w składzie; aktualizowany automatycznie po każdej zmianie rosteru.
- **Cap space** = `salaryCap − totalPayroll`. Dodatni cap space oznacza wolne środki; ujemny oznacza przekroczenie limitu.

## Zakresy wynagrodzeń

### Zawodnicy

- `minPlayerSalary = 1 000 000 €`
- `maxPlayerSalary = 60 000 000 €`

### Sztab

- `minStaffSalary = 500 000 €`
- `maxStaffSalary = 5 000 000 €`
- `staffSalaryCap = 15 000 000 €`
- Staff cap jest liczony osobno od player salary cap i dotyczy wyłącznie aktywnych kontraktów członków sztabu.

## Aktualizacja limitu (prawa telewizyjne)

- Harmonogram nowej umowy TV jest wyznaczany deterministycznie przy tworzeniu save'a z `saveSeed` i bieżącego sezonu.
- Następny reset przypada za **5–7 sezonów** (`currentYear + 5..7`), a wzrost wynosi **4–12%**; oba parametry są znane z góry i zapisane w `Season.nextTvCapResetSeason` oraz `Season.nextTvCapIncreasePct`.
- Aktualizacja jest wykonywana przez event `capUpdateTv` na początku offseasonu — tydzień 44, dzień 1 — i może wykonać się tylko raz w danym sezonie (`capUpdateTvDone`).
- Po aktualizacji wszystkie drużyny dostają nowy `salaryCap`, a oba aprony są skalowane tym samym współczynnikiem. Istniejące kontrakty i payroll pozostają bez zmian.
- Po wykonaniu aktualizacji zapisywany jest kolejny deterministyczny termin i wzrost. Staff salary cap nie jest aktualizowany — pozostaje stały.
- Gracz otrzymuje urgent message o zmianie capu; drużyny dotknięte ograniczeniami dostają także `apronWarning`.

## Cztery poziomy finansowe

Liga operuje poziomami payrollu. Im wyżej znajduje się drużyna, tym mniejsza jej elastyczność w podpisach i wymianach.

| Poziom | Próg | Znaczenie |
| --- | --- | --- |
| **Poniżej cap** | payroll `<= 350 000 000 €` | Pełna elastyczność — podpisy w ramach cap space |
| **Powyżej capu** | `350 000 000 € < payroll < 396 700 000 €` | Matching przy wymianach; agregacja dozwolona |
| **1st apron** | `396 700 000 € <= payroll < 431 700 000 €` | Matching bez agregacji |
| **2nd apron** | payroll `>= 431 700 000 €` | Brak netto wzrostu payrollu i zakaz przyjęcia picka R1 |

Progi przy zachowaniu tych samych proporcji co w poprzednim modelu:

| Próg | Kwota | vs cap |
| --- | --- | --- |
| Salary cap | **350 000 000 €** | 100% |
| 1st apron | **396 700 000 €** | ≈ +13,3% |
| 2nd apron | **431 700 000 €** | ≈ +23,3% |

> Przy każdej aktualizacji TV aprony skalują się tymi samymi procentami względem nowego limitu. Granice są oceniane zgodnie z `SalaryCapService.snapshot`: payroll równy apronowi należy już do danego poziomu.

## Walidacja składu (player cap)

W ekranie finance_screen wyświetla się informacja o potencjalnych możliwościach podpisania kolejnych graczy (ile salary może przyjąć payroll i w jaki sposób).

1. Jeśli `payroll <= salaryCap` → skład **OK**.
2. Jeśli `payroll > salaryCap` → nadwyżka wywołana poprzez wykorzystanie wyjątków.

## Walidacja sztabu (staff cap)

W ekranie finance_screen wyświetla się informacja o obecnym stanie staffCap.

1. Jeśli `totalStaffPayroll <= staffSalaryCap` → sztab **OK**.
2. Jeśli `totalStaffPayroll > staffSalaryCap` → nie legalna nadwyżka - błąd systemu do review.

## Wyjątki cap (players)

Walidacja wyjątków jest scentralizowana w `SalaryCapService.validateExceptionOffer` i sprawdza kwalifikację zawodnika, zakres pensji oraz długość umowy:

- **Rookie Scale:** dokładnie `rookieBaseScale / (1 + pickSlot × 0,06)`, zaokrąglone do pełnych euro i ograniczone do zakresu rookie; maksymalnie 2 lata. Dla skali używana jest baza **8 000 000 €**.
- **Rookie Extension:** tylko dla zawodnika na skali rookie w jej ostatnim roku, wyłączna dla obecnego klubu, **1–60M €**, maksymalnie 5 lat.
- **Qualifying Offer / RFA:** tylko po zakończeniu skali rookie; pensja co najmniej `max(1 000 000 €, ceil(1,25 × ostatnia pensja rookie))`, maksymalnie 5 lat.
- **Full Bird Rights:** staż co najmniej 3 sezonów (albo zachowane prawa Bird), **1–60M €**, maksymalnie 5 lat.
- **Early Bird Rights:** dokładnie 2 sezony w klubie; maksimum `min(175% poprzedniej pensji, 60% maxSalary)`, maksymalnie 4 lata.
- **Non-Bird Rights:** staż krótszy niż 2 sezony; maksimum `120% poprzedniej pensji`, maksymalnie 4 lata.
- **Veteran Extension Raise Cap:** nie dotyczy rookie scale; maksimum `min(60M €, 108% poprzedniej pensji)`, maksymalnie 5 lat.

Wyjątek nie znosi kwalifikacji ani limitu kwotowego: podpis musi przejść również przez `canSign`, a istniejący zawodnik jest rozliczany jako zastępowana pensja, bez podwójnego obciążenia payrollu.

## Pensje

### Zakres pensji zawodników

- Minimum: **1 000 000 €**
- Maximum: **60 000 000 €**
- Całkowity `playerSalaryCap`: **350 000 000 €**
- konkretny wzór oczekiwanej pensji i długości kontraktu w contracts.md

### Zakres pensji sztabu

- Minimum: **500 000 €**
- Maximum: **5 000 000 €**
- Całkowity `staffSalaryCap`: **15 000 000 €**
- konkretny wzór oczekiwanej pensji i długości kontraktu w contracts.md

## Podpisywanie zawodników

- **Poniżej cap:** nowy kontrakt do wysokości dostępnego cap space — bez wyjątków.
- **Powyżej cap:** wymagany odpowiedni wyjątek (`Bird rights`, `Rookie scale`, `Rookie extension` itd.).
- `canSignPlayer(salary, exception)` powinno sprawdzać, czy pensja mieści się w cap space albo w kwocie wyjątku.

Kolejność preferencji przy budowaniu składu:

1. Cap space.
2. Rookie scale.
3. Bird rights / Early Bird / Non-Bird.

## Podpisywanie sztabu

- Kontrakty sztabu przechodzą przez osobną walidację względem `staffSalaryCap`.
- W `Contract extensions` i `FA` można podpisywać staff zgodnie z zasadami z `contracts.md`.
- Jeśli `totalStaffPayroll` przekracza staff cap, podpis niemożliwy (rola pozostaje nie obstawiona)
- Wiek `60` oznacza hard cap emerytury: kontrakt maksymalnie **1 rok**.

## Cash flow

W wersji V1 nie jest zaimplementowany osobny budżet operacyjny. Ograniczenia finansowe wynikają wyłącznie z salary capu, apronów, wyjątków i reguł wymian.

## Ograniczenia przy pułapach

| Poziom | Podpisy | Wymiany |
| --- | --- | --- |
| Poniżej cap | Pełna elastyczność w cap space | Maksimum incoming = outgoing + dostępny cap space |
| Powyżej capu, poniżej 1st apron | Wyjątki (`Bird`, `Rookie`) | Matching `125% outgoing + 500 000 €`; agregacja dozwolona |
| Od 1st apronu do poniżej 2nd apronu | Tylko zgodnie z dostępnymi wyjątkami i bez zwiększania ograniczeń apronów | Matching `125% jednej pensji outgoing + 500 000 €`; agregacja zabroniona |
| Od 2nd apronu | Tylko zgodnie z regułami hard capu | Incoming `<= outgoing`; brak netto wzrostu payrollu i zakaz przyjęcia picków R1 |

W przedziale między apronami `SalaryCapService` wybiera jedną pensję outgoing jako podstawę matchingu; pozostałe kontrakty nie mogą być agregowane. Powyżej 2nd apronu zakaz picków R1 dotyczy picków przyjmowanych przez tę drużynę.

## Brak zwolnień (kanon V1)

**Nie istnieje mechanizm zwolnienia zawodnika ani członka sztabu.** Kontrakt można zakończyć wyłącznie przez:

| Ścieżka | Dotyczy | Skutek dla payrollu |
| ------- | ------- | ------------------- |
| Wygaśnięcie kontraktu (`yearsRemaining = 0`) | zawodnicy, sztab | pensja schodzi z payrollu |
| Wymiana do innego klubu | zawodnicy | pensja przechodzi do klubu docelowego |
| Emerytura zawodnika (33+) | zawodnicy | pensja schodzi z payrollu — `offseason.md` |
| Emerytura sztabu (wiek 60) | sztab | pensja schodzi ze staff payrollu — `staff.md` |

### Konsekwencje projektowe

- **Nie ma dead money** — bo nie ma sposobu na przedwczesne rozwiązanie umowy. Pojęcie nie występuje w modelu.
- **Niekorzystny kontrakt jest realnym obciążeniem.** Jedyne wyjście to wymiana, a to wymaga oddania wartości (picka lub lepszego zawodnika) jako zachęty dla partnera — `trades.md`.
- Przepłacony zawodnik z długim kontraktem blokuje cap space do wygaśnięcia umowy. To celowa konsekwencja decyzji kontraktowych, nie luka.
- Roster **nie może** zejść poniżej 20 z inicjatywy menedżera — jedyną drogą poniżej limitu jest emerytura (`squad_management.md`).
- Przy rosterze 30 podpisanie kolejnego zawodnika wymaga uprzedniej **wymiany**, nie zwolnienia.
- Slot sztabu można opróżnić tylko przez wygaśnięcie kontraktu lub emeryturę — nie da się zwolnić słabego trenera w trakcie umowy.

Reguła obowiązuje jednakowo gracza i AI (`AI_behaviour.md`).

---

## Po wygaśnięciu kontraktu

- Zawodnik bez kontraktu staje się **UFA** albo **RFA** (jeśli złożono QO).
- Klub traci wpis pensji z payrollu — cap space rośnie o zwolnioną kwotę.
- Bird rights wygasają, jeśli klub nie zachowa ścieżki przedłużenia zgodnej z zasadami kontraktowymi.
- Rookie po 2 latach scale przechodzi do RFA (z QO) albo UFA (bez QO).
- Członek sztabu bez przedłużenia przechodzi do puli FA staff.