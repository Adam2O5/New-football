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

- Limit pensji jest uzgadniany co **5–7 lat** przy podpisaniu nowej umowy na prawa telewizyjne ligi.
- Dokładny rok zmiany jest znany z góry w momencie podpisania umowy TV i powinien być widoczny w ekranie finansów jako „następny reset capu: sezon X”.
- Wzrost capu zależy od wartości kontraktu medialnego.
- Po aktualizacji capu przeliczane są wszystkie progi apronów; istniejące kontrakty pozostają bez zmian do wygaśnięcia.
- Staff salary cap nie jest aktualizowany - pozostaje cały czas ten sam.

Limit pensji jest zmieniany na początku offseason - informacja poprzez urgent message i ma natychmiastowy wpływ. Salary cap może się zmienić w zakresie -10% - +10%.

## Trzy pułapy finansowe

Liga operuje poziomami payrollu. Im wyżej znajduje się drużyna, tym mniejsza jej elastyczność w podpisach i wymianach.

| Pułap | Próg | Znaczenie |
| --- | --- | --- |
| **Poniżej cap** | payroll `<= 350 000 000 €` | Pełna elastyczność — podpisy w ramach cap space |
| **1st apron** | `350 000 000 € < payroll <= 396 700 000 €` | Soft cap — ograniczone wymiany |
| **Między apronami** | `396 700 000 € < payroll <= 431 700 000 €` | Brak agregacji w wymianach; wyższy podatek |
| **2nd apron** | payroll `> 431 700 000 €` | Twardy reżim — brak netto wzrostu w trade, najwyższy podatek |

Progi przy zachowaniu tych samych proporcji co w poprzednim modelu:

| Próg | Kwota | vs cap |
| --- | --- | --- |
| Salary cap | **350 000 000 €** | 100% |
| 1st apron | **396 700 000 €** | ≈ +13,3% |
| 2nd apron | **431 700 000 €** | ≈ +23,3% |

> Przy każdej aktualizacji TV aprony skalują się tymi samymi procentami względem nowego limitu.

## Walidacja składu (player cap)

W ekranie finance_screen wyświetla się informacja o potencjalnych możliwościach podpisania kolejnych graczy (ile salary może przyjąć payroll i w jaki sposób).

1. Jeśli `payroll <= salaryCap` → skład **OK**.
2. Jeśli `payroll > salaryCap` → nadwyżka wywołana poprzez wykorzystanie wyjątków.

## Walidacja sztabu (staff cap)

W ekranie finance_screen wyświetla się informacja o obecnym stanie staffCap.

1. Jeśli `totalStaffPayroll <= staffSalaryCap` → sztab **OK**.
2. Jeśli `totalStaffPayroll > staffSalaryCap` → nie legalna nadwyżka - błąd systemu do review.

## Wyjątki cap (players)

Wyjątki szczegółowo opisane w contracts.md

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

W wersji V1 nie będzie zaimplementowana funkcjonalność osobnego budżetu operacyjnego i związanych z nim kosztów i przychodów. Dodatkowy podatek od luksusu po przekroczeniu salary cap nie ma więc wiekszych konsekwencji poza ograniczeniami w wymianach i podpisywaniu zawodników.

## Ograniczenia przy pułapach

| Poziom | Podpisy | Wymiany |
| --- | --- | --- |
| Poniżej cap | Pełna elastyczność w cap space | Bez dopasowania pensji |
| Powyżej cap, poniżej 1st apron | Wyjątki (`Bird`, `Rookie`) | Matching 125% + TPE; agregacja dozwolona |
| 1st apron – 2nd apron | Tylko obniżanie lub utrzymanie payrollu | Brak agregacji |
| Powyżej 2nd apron | Tylko obniżanie payrollu  | Brak netto wzrostu pensji |

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