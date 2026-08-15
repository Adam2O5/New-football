# Sztab klubu

## 1. Role (po 1 slocie)

| Rola | EN (kod) | Główne zadanie |
| ---- | -------- | -------------- |
| **Trener główny** | `headCoach` | taktyka i motywacja pierwszej drużyny |
| **Trener rozwojowy** | `developmentCoach` | rozwój graczy |
| **Scout** | `scout` | obserwacja prospectów draftu |
| **Fizjo** | `physio` | regeneracja, prewencja kontuzji |
| **Lekarz** | `doctor` | zapobieganie i leczenie kontuzji |
| **CFO** | `cfo` | wsparcie negocjacji kontraktowych |

Każdy klub ma dokładnie te **6 slotów** (mogą być puste -> brak kara zamiast boosta).

---

## 2. Profil członka sztabu

| Pole | Skala / reguła |
| ---- | -------------- |
| Wiek | **35–60** (generacja / hire w tym zakresie) |
| Narodowość + imię / nazwisko | z puli kraju |
| Atrybuty roli | **0,5–5 ★**, krok **0,5** |
| Kontrakt | lata + pensja roczna (wliczana do **staff salary cap**) |

W poniższych tabelach doprecyzowane jest jakie boosty dają konkretne wartości atrybutu. 0 ★ oznacza brak odpowiadającego członka sztabu (najczęściej niekorzystny "boost", który ma symulować karę za brak członka).

### Atrybuty per rola (propozycja)

| Rola | Atrybuty ★ |
| ---- | ---------- |
| Head Coach | **Tactics**, **Motivation** |
| Development Coach | **Development**, **Mentoring** |
| Scout | **Coverage**, **Evaluation** |
| Physio | **Rehabilitation**, **Regeneration** |
| Doctor | **Prevention**, **Care** |
| CFO | **Negotiation** |

---

## 3. Staff salary cap (założenia ogólne)

Osobny limit od salary cap zawodników (`salary_cap.md`).

---

## 4. Scout

### Zadanie

Odpowiada za skauting prospectów kolejnego draftu.

### Atrybuty

| Atrybut | Znaczenie |
| ------- | --------- |
| **Coverage** | maksymalna liczba prospectów obserwowanych jednocześnie |
| **Evaluation** | szybkość scoutingu |

### Coverage

```text
maxWatched = round(4 + Coverage × 6)   // np. 0★→4, 2.5★→19, 5★→34
```

### Kalendarz skautingu

1. **Od wtorku tyg. 46 (dzień po drafcie):** gracz przypisuje scouta do prospectów klasy N+1 (do limitu Coverage).
2. **Ciągle przez rok:** scout przesyła raporty do inboxa pierwszego dnia każdego kolejnego miesiąca.
3. **Scout Report (pon 45):** snapshot całej zdobytej wiedzy + **assign Combine** — limit = **½ Coverage** (zaokrąglenie w dół).
4. **Combine (śr 45):** przypisane prospecty → wyższa szansa poprawego oszacowania injuryProne / determination.
5. **Mock finalny (pt 45):** finalny power ranking prospectów według mediów:  
   `Top 1` · `Top 3` · `Top 5` · `Top 10` · `R1` · `R2` · `R3` · `X`.

### Tiery informacji (5 poziomów)

| Tier | Odkrywane dane | Potrzebna ilość dni scoutowania (bazowa) |
| ---- | -------------------- | ---------------------------------- |
| 1 | pozycja, wiek, narodowość |
| 2 | zakres overall |
| 3 | estymowany slot, zawężenie zakresu overall |
| 4 | estymowany potencjał ★ |
| 5 | oszacowanie `injuryProne` i `determination`, zawężenie zakresu overall |

#### Tier 1

Dane prospectów są ogólnodostępne i wiadome od razu

#### Tier 2

Zakres overall o 10 (prawdziwa wartość zakresie), np. 73 -> 67 - 76

#### Tier 3

Przypisanie jednego z `Top 1` · `Top 3` · `Top 5` · `Top 10` · `R1` · `R2` · `R3` · `X`.
Zawężenie zakresu overall o 3 punkty (prawdziwa wartość dalej w zakresie), np. 73 -> 67 - 73

#### Tier 4

Określenie estymowanego potencjału zawodnika, możliwe odchylenie o max 1 gwiazdkę w każdą stronę, np. 3,5 ★ -> 4,5 ★

#### Tier 5

Oszacowanie `injuryProne` i `determination` - podanie zakresu o 5 względem prawdziwej wartości, np. 8 -> 6 - 10.
Zawężenie zakresu overall o kolejne 4 punkty (prawdziwa wartość dalej w zakresie), np. 73 -> 71 - 73

### Evaluation

| Evaluation | Tier 1  | Tier 2  | Tier 3  | Tier 4  | Tier 5  |
| ---------- | ------- | ------- | ------- | ------- | ------- |
| 5,0 ★      | od razu | 20 tyg. | 10 tyg. | 10 tyg. | 10 tyg. |
| 4,5 ★      | od razu | 21 tyg. | 11 tyg. | 11 tyg. | 11 tyg. |
| 4,0 ★      | od razu | 22 tyg. | 12 tyg. | 12 tyg. | 12 tyg. |
| 3,5 ★      | od razu | 23 tyg. | 13 tyg. | 13 tyg. | 13 tyg. |
| 3,0 ★      | od razu | 24 tyg. | 14 tyg. | 14 tyg. | 14 tyg. |
| 2,5 ★      | od razu | 25 tyg. | 15 tyg. | 15 tyg. | 15 tyg. |
| 2,0 ★      | od razu | 26 tyg. | 16 tyg. | 16 tyg. | 16 tyg. |
| 1,5 ★      | od razu | 27 tyg. | 17 tyg. | 17 tyg. | 17 tyg. |
| 1,0 ★      | od razu | 28 tyg. | 18 tyg. | 18 tyg. | 18 tyg. |
| 0,5 ★      | od razu | 29 tyg. | 19 tyg. | 19 tyg. | 19 tyg. |
| 0 ★ (brak scouta) | od razu | - | - | - | - |

### Comiesięczne raporty skauta

Scout wysyła wiadomość z aktualnymi danymi - dane są dostępne cały czas w watchlist_screen.

---

## 5. Head Coach

### Zadanie

Odpowiada za taktykę, prowadzenie pierwszej drużyny, motywację zespołu i ogólną skuteczność meczu.

### Atrybuty

| Atrybut | Znaczenie |
| --- | --- |
| **Tactics** | jakość ustawienia, dopasowanie stylu gry i decyzji meczowych |
| **Motivation** | wpływ na morale, atmosferę w szatni i reakcję zespołu w trudnych momentach |

### Tactics

Dodaje stały boost taktyczny do ustawienia — punkty dodawane bezpośrednio do `def` / `mid` / `atk` drużyny, niezależnie od formacji i innych ustawień.

| Tactics            | Boost (def / mid / atk) |
| ------------------ | ----------------------- |
| 0 ★ (brak trenera) | −5                      |
| 0,5 ★              | 0                       |
| 1,0 ★              | +1                      |
| 1,5 ★              | +2                      |
| 2,0 ★              | +3                      |
| 2,5 ★              | +4                      |
| 3,0 ★              | +5                      |
| 3,5 ★              | +6                      |
| 4,0 ★              | +7                      |
| 4,5 ★              | +8                      |
| 5,0 ★              | +9                      |

### Motivation

Dodaje mnożnik do `lineupCohesion`.

| Motivation         | Mnożnik |
| ------------------ | ------- |
| 0 ★ (brak trenera) | ×0,95   |
| 0,5 ★              | ×1,00   |
| 1,0 ★              | ×1,01   |
| 1,5 ★              | ×1,02   |
| 2,0 ★              | ×1,03   |
| 2,5 ★              | ×1,04   |
| 3,0 ★              | ×1,05   |
| 3,5 ★              | ×1,06   |
| 4,0 ★              | ×1,07   |
| 4,5 ★              | ×1,08   |
| 5,0 ★              | ×1,09   |

## 6. Development Coach

### Zadanie

Odpowiada za rozwój zawodników, szczególnie młodych.

### Atrybuty

| Atrybut | Znaczenie |
| --- | --- |
| **Development** | tempo rozwoju zawodników |
| **Mentoring** | wpływ na młodych graczy, adaptację i stabilny rozwój |

### Development

Dodaje bonus do growthRate.

| Development        | bonus   |
| ------------------ | ------- |
| 0 ★ (brak trenera) | -0,10   |
| 0,5 ★              | +0,01   |
| 1,0 ★              | +0,02   |
| 1,5 ★              | +0,03   |
| 2,0 ★              | +0,05   |
| 2,5 ★              | +0,06   |
| 3,0 ★              | +0,08   |
| 3,5 ★              | +0,09   |
| 4,0 ★              | +0,11   |
| 4,5 ★              | +0,12   |
| 5,0 ★              | +0,14   |

### Mentoring

Dodaje mnożnik do rozwoju zawodników poniżej 26 roku życia (stosowany dodatkowo, obok `Development`).

| Mentoring          | bonus   |
| ------------------ | ------- |
| 0 ★ (brak trenera) | -0,10   |
| 0,5 ★              | +0,01   |
| 1,0 ★              | +0,02   |
| 1,5 ★              | +0,03   |
| 2,0 ★              | +0,05   |
| 2,5 ★              | +0,06   |
| 3,0 ★              | +0,08   |
| 3,5 ★              | +0,09   |
| 4,0 ★              | +0,11   |
| 4,5 ★              | +0,12   |
| 5,0 ★              | +0,14   |

## 7. Physio

### Zadanie

Odpowiada za regenerację zawodników, rehabilitację i zmniejszanie skutków urazów.

### Atrybuty

| Atrybut | Znaczenie |
| --- | --- |
| **Rehabilitation** | skuteczność powrotu po kontuzji |
| **Regeneration** | tempo odzyskiwania sił i ograniczania zmęczenia |

### Rehabilitation

Dodaje mnożnik do prawdopodobieństwa odniesienia kontuzji przez zawodników zespołu.

| Rehabilitation   | Mnożnik ryzyka kontuzji |
| ---------------- | ----------------------- |
| 0 ★ (brak fizjo) | ×1,05                   |
| 0,5 ★            | ×1,00                   |
| 1,0 ★            | ×0,99                   |
| 1,5 ★            | ×0,98                   |
| 2,0 ★            | ×0,96                   |
| 2,5 ★            | ×0,95                   |
| 3,0 ★            | ×0,93                   |
| 3,5 ★            | ×0,92                   |
| 4,0 ★            | ×0,90                   |
| 4,5 ★            | ×0,89                   |
| 5,0 ★            | ×0,87                   |

### Regeneration

Dodaje mnożnik do odzyskiwanej energii (staminy) przez zawodników zespołu.

| Regeneration     | Mnożnik regeneracji staminy |
| ---------------- | --------------------------- |
| 0 ★ (brak fizjo) | ×0,95                       |
| 0,5 ★            | ×1,00                       |
| 1,0 ★            | ×1,01                       |
| 1,5 ★            | ×1,02                       |
| 2,0 ★            | ×1,04                       |
| 2,5 ★            | ×1,05                       |
| 3,0 ★            | ×1,07                       |
| 3,5 ★            | ×1,08                       |
| 4,0 ★            | ×1,10                       |
| 4,5 ★            | ×1,11                       |
| 5,0 ★            | ×1,13                       |

## 8. Doctor

### Zadanie

Odpowiada za profilaktykę, diagnozowanie i leczenie kontuzji.

### Atrybuty

| Atrybut | Znaczenie |
| --- | --- |
| **Prevention** | ograniczanie ryzyka kontuzji |
| **Care** | skuteczność leczenia i obsługi medycznej |

### Prevention

Dodaje mnożnik do prawdopodobieństwa odniesienia kontuzji przez zawodników zespołu.

| Prevention         | Mnożnik ryzyka kontuzji |
| ------------------ | ----------------------- |
| 0 ★ (brak lekarza) | ×1,05                   |
| 0,5 ★              | ×1,00                   |
| 1,0 ★              | ×0,99                   |
| 1,5 ★              | ×0,98                   |
| 2,0 ★              | ×0,96                   |
| 2,5 ★              | ×0,95                   |
| 3,0 ★              | ×0,93                   |
| 3,5 ★              | ×0,92                   |
| 4,0 ★              | ×0,90                   |
| 4,5 ★              | ×0,89                   |
| 5,0 ★              | ×0,87                   |

### Care

Dodaje mnożnik do początkowego czasu trwania kontuzji.

| Care               | Mnożnik czasu trwania kontuzji |
| ------------------ | ------------------------------ |
| 0 ★ (brak lekarza) | ×1,05                          |
| 0,5 ★              | ×1,00                   |
| 1,0 ★              | ×0,99                   |
| 1,5 ★              | ×0,98                   |
| 2,0 ★              | ×0,96                   |
| 2,5 ★              | ×0,95                   |
| 3,0 ★              | ×0,93                   |
| 3,5 ★              | ×0,92                   |
| 4,0 ★              | ×0,90                   |
| 4,5 ★              | ×0,89                   |
| 5,0 ★              | ×0,87                   |

## 9. CFO 

### Zadanie

Odpowiada za wsparcie negocjacji kontraktowych.

### Atrybuty

| Atrybut | Znaczenie |
| --- | --- |
| **Negotiation** | siła negocjacyjna, obniżanie oczekiwań kontraktowych |

### Negotiation

Dodaje mnożnik do `offerScore` przy negocjacjach kontraktowych.

| Negotiation    | Mnożnik offerScore |
| -------------- | ------------------ |
| 0 ★ (brak CFO) | ×0,95              |
| 0,5 ★          | ×1,00              |
| 1,0 ★          | ×1,01              |
| 1,5 ★          | ×1,02              |
| 2,0 ★          | ×1,04              |
| 2,5 ★          | ×1,05              |
| 3,0 ★          | ×1,07              |
| 3,5 ★          | ×1,08              |
| 4,0 ★          | ×1,10              |
| 4,5 ★          | ×1,11              |
| 5,0 ★          | ×1,13              |

---