# Zarządzanie zawodnikiem — atrybuty, rozwój, potencjał, kontuzje, eventy losowe

---

## Profil zawodnika

| Element | Skala / typ | Widoczność |
| ------- | ----------- | ---------- |
| name | string | jawna |
| nationality | enum | jawna |
| date of birth | date | jawna |
| heightCm | int | jawna |
| Pozycja (`Position`) | enum | jawna |
| Optymalna rola | enum | ukryta u prospectów/ jawna u zawodników |
| Overall | 50–99 | jawny |
| Atrybuty | 50–99 | jawne |
| Stamina | 0–100 | jawna |
| Form | 1–10 | jawna |
| Osobowość (`PlayerPersonality`) | enum | jawna |
| Potencjał (gwiazdki) | 0,5–5,0 (krok 0,5) | ukryty u prospectów/ jawna u zawodników |
| `injuryProne` | 1–10 | ukryty |
| `determination` | 1–10 | ukryty |
| `overallProgress` | 0–99% | ukryty |
| `growthRate` | -3 – 3 | ukryty |
| `pointValue` | −1000…1000 | jawny |
| `developmentOutcome` | exceed/hit/under | ukryty |
| `seasonsWithTeam` | int | jawny |
| `seasonStats` | List<class> | jawny |
| `contract` | class | jawny |

---

## Elementy jawne

### Informacje personalne

W ich skład wchodzą: name, nationality, date of birth, heightCm. Dane te są generowane przy tworzeniu prospectu/zawodnika.

### Personality

Osobowość wpływa na  m.in. zgranie, atmosferę, decyzje kontraktowe i eventy losowe.

| Osobowość | Cecha (efekt) |
| --------- | ------------- |
| `professional` | mniejsza szansa kontuzji o 20% |
| `leader` | boost zgrania i atmosfery (`team_management.md`); dodatkowe bonusy dla drużyny w trakcie meczu (`matchday_model.md`) |
| `temperamental` | problematyczny w szatni (`team_management.md`); więcej kartek (`matchday_model.md`) i wahań formy |
| `ambitious` | growth rate zwiększony o 10%; bardziej wymagający od innych zawodników (`team_management.md`) |
| `loyal` | mniej wymagający od innych zawodników (`team_management.md`) |
| `balanced` | brak dodatkowych cech |

Rozkład osobowości dla graczy jest jednakowo losowy.

### Position

Każdy gracz ma jedną optymalną pozycję. Nie występowanie w optymalnej pozycji wiąże się z debuffami (szerzej opisane w poszczególnych fragmentach dokumentacji). Rozkład pozycji dla graczy jest jednakowo losowy.

### Optymalna rola

Każdy gracz ma jedną optymalną rolę. Występowanie w optymalnej roli wiąże się z buffami (szerzej opisane w poszczególnych fragmentach dokumentacji). Rozkład roli dla graczy jest jednakowo losowy.

### Atrybuty

Inspiracja: karty FUT. Sześć statystyk buduje **overall**.

| Atrybut | Zakres | Znaczenie (skrót) |
| ------- | ------ | ----------------- |
| Pace | 50–99 | szybkość, przyspieszenie |
| Shooting | 50–99 | wykończenie, strzał |
| Passing | 50–99 | podania, wizja |
| Dribbling | 50–99 | prowadzenie piłki, pierwszy kontakt |
| Defending | 50–99 | odbiór, krycie, pozycjonowanie |
| Physicality | 50–99 | siła, agresja, wytrzymałość |

### Overall

Głowny wyznacznik jakości i wartości zawodnika.

- Overall ∈ **[50, 99]** (zaokrąglenie do liczby całkowitej w UI).
- Liczony na podstawie wag dla każdej pozycji osobno. Wagi atrybutów dla każdej pozycji są zdefiniowane w `balance_config.dart` w `_defaultOutfieldOverallWeights`.

### Stamina

Bieżące „siły do gry”: spada przy minutach, regeneruje się między meczami.

#### Zużycie w meczu
Bazowe zużycie zależy od intensywności biegowej pozycji. Zawodnik grający mniej minut zużywa proporcjonalnie mniej, liniowo względem rozegranych minut.

| Grupa pozycji | Pozycje | Zużycie / 90 min | Zużycie / minutę |
| --- | --- | ---: | ---: |
| Bramkarz | `gk` | 15 | 0,16 |
| Środkowy obrońca | `cb` | 65 | 0,72 |
| Boczny obrońca | `lb`, `rb` | 75 | 0,83 |
| Wahadłowy | `lwb`, `rwb` | 85 | 0,94 |
| Defensywny pomocnik | `cdm` | 70 | 0,77 |
| Środkowy pomocnik | `cm` | 70 | 0,77 |
| Ofensywny pomocnik | `cam` | 70 | 0,77 |
| Skrzydłowy | `lw`, `rw` | 80 | 0,88 |
| Napastnik | `st` | 70 | 0,77 |

**Modyfikatory zużycia**  

| Czynnik | Mnożnik |
| --- | ---: |
| `Tempo.fast` | ×1,15 |
| `Tempo.slow` | ×0,90 |
| `PressingIntensity.high` | ×1,10 |
| `PressingIntensity.gegenpressing` | ×1,20 |
| `PressingIntensity.low` | ×0,90 |
| Pogoda: `heat` | ×1,15 |
| Derby (`isDerby`) | ×1,05 |

Niska stamina obniża wkład meczowy i zwiększa ryzyko kontuzji.

#### Regeneracja staminy

Bazowo gracz regeneruje 20 staminy na dzień oraz 20 od razu po meczu.

**Clamp:** `stamina ∈ [0, 100]`

#### Progi wpływu na wkład meczowy

| Stamina | `performanceMult` | Opis |
| --- | ---: | --- |
| 80–100 | 1,00 | pełna dyspozycja |
| 60–79 | 0,97 | lekki spadek |
| 40–59 | 0,90 | zauważalne osłabienie |
| 20–39 | 0,75 | wyraźny spadek jakości |
| 0–19 | 0,50 | wykończony, gra „na siłę” |

#### Progi wpływu na ryzyko kontuzji

| Stamina | `injuryRiskMult` | Opis |
| --- | ---: | --- |
| 80–100 | 0,90 | znikome ryzyko |
| 60–79 | 1,00 | brak kary |
| 40–59 | 1,20 | lekki mnożnik |
| 20–39 | 1,40 | silny mnożnik |
| 0–19 | 1,67 | krytyczne ryzyko |

### Form

Krótki streak formy (ostatnie 5 meczów): wpływa na skuteczność w meczu.

| Forma | `formMult` | Opis |
| --- | ---: | --- |
| 1 | 0,90 | fatalna dyspozycja, kryzys formy |
| 2 | 0,92 | bardzo słaba |
| 3 | 0,95 | słaba |
| 4 | 0,97 | poniżej oczekiwań |
| 5 | 0,99 | lekko poniżej normy |
| 6 | 1,00 | baseline, przeciętna forma |
| 7 | 1,04 | dobra |
| 8 | 1,07 | bardzo dobra |
| 9 | 1,09 | znakomita |
| 10 | 1,12 | szczytowa forma |

### Potencjał (gwiazdki)

Gwiazdki opisują **przybliżony sufit overall**, nie bieżącą ocenę.

| Potencjał (★) | Przybliżony sufit overall |
| ------------- | ------------------------- |
| 0,5 | 50–55 |
| 1,0 | 56–60 |
| 1,5 | 61–65 |
| 2,0 | 66–70 |
| 2,5 | 71–75 |
| 3,0 | 76–80 |
| 3,5 | 81–84 |
| 4,0 | 85–88 |
| 4,5 | 89–92 |
| 5,0 | 93–99 |

### Wykorzystanie potencjału

Osobny roll development outcome, który determinuje czy zawodnik osiągnie potencjał, szczegoly poniżej.

### Spadek potencjału

- **Major injury** ma 10% szans, żeby obniżyć potencjał o **0,5★**.
- Clamp dolny: 0,5★.
- Minor injuries **nie** obniżają potencjału.

### pointValue

Główny wyznacznik wartości gracza. Kluczowy dla wymian i negocjacji kontraktowych. Ograniczony do przedziału od -1000 do 1000 punktów. Składa się z sumy czterech komponentów:

`pointValue = clamp(round(ovrComponent + potentialComponent + ageComponent + contractComponent), -1000, 1000)`

**1. Komponent overall (`ovrComponent`)**  
Twardy wyznacznik obecnej jakości gry na dziś (baza wartości).

- **Formuła:** `(overall - 70) * 30`

- **Zakres:** `-600` (przy 50 OVR) do `+870` (przy 99 OVR)

**2. Komponent potencjału (`potentialComponent`)**  
Premia za niewykorzystaną górkę rozwoju. Najmocniej dotyczy młodych zawodników, ale także gracze starsi niż 26 lat zachowują niewielki dodatkowy bonus, jeśli ich `overall` nadal jest wyraźnie poniżej potencjalnego sufitu.

- **Formuła:**  
  `potentialGap * (4,5 * youngFactor + olderFactor)`

- **Zmienne:**
  - `potentialGap`: różnica między sufitem potencjału dla danego ★ a obecnym `overall`:  
    `max(0, ceilingOvr - overall)`
  - `youngFactor`: główny mnożnik dla młodych zawodników:  
    `age <= 26 ? max(0, 4.5 - 0.5 * (age - 18)) : 0`
  - `olderFactor`: dodatkowy, wygaszany bonus dla starszych zawodników:  
    `age >= 27 ? max(0.15, 0.8 - 0.08 * (age - 27)) : 0`

- **Zakres:** `0 ... +160`

**3. Komponent wieku (`ageComponent`)**  
Wskazuje na długość pozostałej kariery i ryzyko spadku umiejętności, niezależnie od gwiazdek potencjału.

- **Formuła:** `ageScore * 150`

- **Zmienne:**  
  `ageScore = 1.0` dla wieku `<= 24`,  
  `ageScore = -1.0` dla wieku `>= 34`,  
  pomiędzy 24 a 34 spadek liniowy.

- **Zakres:** `-150 ... +150`

**4. Komponent kontraktowy (`contractComponent`)**  
Ocenia, czy umowa zawodnika jest atrakcyjna względem estymowanej pensji wynikającej z jego `overall`.

- **Formuła:**  
  `salaryScore * 260 * (0.5 + 0.5 * lengthFactor)`

- **Zmienne:**
  - `estimatedSalary`:  
    `round(minSalary + (maxSalary - minSalary) * (((overall - 50) * 2 / 100) ^ 3), 2)`  
    gdzie `minSalary = 1_000_000`, `maxSalary = 60_000_000`
  - `salaryScore`:  
    `clamp(1.0 - salary / estimatedSalary, -1.0, 1.0)`
  - `lengthFactor`:  
    `clamp(yearsRemaining / 5, 0.0, 1.0)`

- **Zakres:** około `-260 ... +260`

**Przykładowe profile:**
* **Gwiazda** (28 lat, 90 OVR, kontrakt 3 lata, +3 mln)
* **Prospekt** (19 lat, 62 OVR, 4,5★, rookie scale dla picku 35)
* **Weteran** (36 lat, 70 OVR, przepłacony, 3 lata kontraktu, +10 mln)
* **Przeciętniak** (33 lata, 74 OVR, uczciwy krótki kontrakt 1 rok, -1mln)

| Profil       | ovrComponent | potentialComponent | ageComponent | contractComponent | pointValue |
| ------------ | ------------ | ------------------ | ------------ | ----------------- | ---------- |
| Gwiazda      | 600          | 0.0                | 30.0         | -20.0             | 610        |
| Prospekt     | -240         | 468.0              | 150.0        | -37.3             | 341        |
| Weteran      | 0            | 0.3                | -150.0       | -208.0            | -358       |
| Przeciętniak | 120          | 0.0                | -120.0       | 20.7              | 21         |

### seasonsWithTeam

Informacja o tym ile lat gracz spędził z zespołem. Aktualizowane po playoff przy starcie offseason.

### seasonStats

Zawiera wszystkie kluczowe statystyki z sezonów rozegranych przez gracza.

### contract

Zawiera wszystkie szczegóły kontraktowe.

---

## Elementy niejawne

Niedostępne do określenia.

### `injuryProne`

Podatność na kontuzje. Determinuje wartość mnożnika szansy na odniesienie urazu.
**1** = bardzo odporny, **10** = bardzo podatny.

| injuryProne | Mnożnik ryzyka |
| ----------- | -------------- |
| 1           | 0,50           |
| 2           | 0,625          |
| 3           | 0,75           |
| 4           | 0,875          |
| 5           | 1,00           |
| 6           | 1,20           |
| 7           | 1,40           |
| 8           | 1,60           |
| 9           | 1,80           |
| 10          | 2,00           |

### `determination`

Szansa, że zawodnik **wykorzysta** (lub przekroczy / nie dojdzie do) potencjału gwiazdkowego.

| determination | Exceed | Hit | Under | Bazowy growthRate |
| ------------- | ------ | --- | ----- | ----------------- |
| 1             | 1%     | 20% | 79%   | 0,50              |
| 2             | 2%     | 28% | 70%   | 0,65              |
| 3             | 4%     | 36% | 60%   | 0,80              |
| 4             | 7%     | 43% | 50%   | 0,90              |
| 5             | 10%    | 50% | 40%   | 1,00              |
| 6             | 12%    | 58% | 30%   | 1,10              |
| 7             | 15%    | 65% | 20%   | 1,20              |
| 8             | 20%    | 70% | 10%   | 1,30              |
| 9             | 25%    | 68% | 7%    | 1,40              |
| 10            | 30%    | 65% | 5%    | 1,50              |

### `overallProgress`

Niejawny wskaźnik: **ile pozostało** do przyrostu kolejnego OVR. Wskaźnik przyjmuje wartości od 0% do 100%. Gdy wartość osiąga 100% zawodnik otrzymuje +1 punkt do każdego z 6 atrybutów, a sam wskaźnik jest zerowany.

### `growthRate`

Niejawny mnożnik tempa postępu w treningach i meczach. Bazowy growthRate jest zależny od determination. Po 32 roku życia gracze dostają -1 do growth rate postępujące liniowo do -3 w wieku 39 lat.

| Czynnik | Kierunek (orientacja) |
| ------- | --------------------- |
| Forma wysoka (8–10) | +0.05…+0.15 |
| Forma niska (1–3) | −0.15…-0.05 |
| Head Coach / Youth Coach Development ★ | `staff.md` |
| Atmosfera drużyny | -0.10…+0.10 |
| Regularne minuty | +0,01 za każdą rozegraną minutę w meczach w tym tygodniu |
| Wiek | tabela poniżej |

| Wiek | Dodatek |
| ---- | ------- |
| 18   | +0,4    |
| 19   | +0,34   |
| 20   | +0,29   |
| 21   | +0,23   |
| 22   | +0,17   |
| 23   | +0,11   |
| 24   | +0,06   |
| 25   | +0,00   |
| 26   | +0,00   |
| 27   | +0,00   |
| 28   | +0,00   |
| 29   | +0,00   |
| 30   | +0,00   |
| 31   | +0,00   |
| 32   | -0,50   |
| 33   | -1,00   |
| 34   | -1,50   |
| 35   | -1,75   |
| 36   | -2,00   |
| 37   | -2,25   |
| 38   | -2,50   |
| 39   | -2,75   |
| 40   | -3,00   |

Clamp końcowy: **-3.0 – 3.0**.

---

## Rozwój (development)

### Fazy wiekowe

| Wiek | Faza | Przyrost atrybutów / overall |
| ---- | ---- | ---------------------------- |
| ≤ 26 | Development | pełny / normalny wzrost w kierunku sufitu |
| 27–32 | Peak | przyrost **znacznie mniejszy**; utrzymanie formy ważniejsze |
| ≥ 33 | Decline | statystyki **zaczynają spadać** |

Uwaga: „do 26. roku” = wzrost do dnia, w którym zawodnik kończy 26 lat.

### Cel rozwoju

- Soft target = losowany wynik ścieżki względem **gwiazdek potencjału** i `determination` (poniżej).
- Tempo dojścia: `growthRate`.
- Head Coach / Youth Coach Development ★ (`staff.md`) wpływają przez `growthRate`.

### DevelopmentOutcome

Wynik ścieżki kariery (ustalany raz przy tworzeniu, nie co mecz):

| Wynik | Znaczenie |
| ----- | --------- |
| **Exceed** | overall-sufit lepszy niż gwiazdki (**0,5★ lub 1,0★** wyższy) |
| **Hit** | osiągnięcie potencjału |
| **Under** | nieosiągnięcie: sufit o **0,5★ lub 1,0★** niższy |

Przy **Under**: 60% szans na −0,5★, 40% na −1,0★.  
Przy **Exceed**: 80% szans na +0,5★, 20% na +1,0★.

### DevelopmentOutcome, a growthRate

Szybkość rozwoju jest determinowana poprzez growthRate, natomiast realny potencjał przez połączenie developmentOutcome oraz gwiazdek potencjału. 
Jeśli zawodnik nie odpowiednich warunków/ jego determinacja jest za niska to pomimo exceed może nie wypełnić swojego realnego potencjału z powodu zbyt niskiego growthRate.

### Postęp

Rozwój każdego zawodnika jest koreślany przez iloczyn dwóch czynników: growthRate * constDev.
ConstDev to stała bazowego postępu zawodnika w okresie tygodniowym i wynosi **3,67**. 
Na koniec każdego tygodnia przeliczany jest obecny growthRate każdego zawodnika, przemnażany przez constDev i dodawany do overallProgress jako wartość procentowa. 
Overflow ponad 100% jest tracony, np: growthRate = 1,97, overallProgress = 95,17%; constDev*growthRate=7,23 -> overallProgress = 102,40% -> atrybuty + 1 i overallProgress = 0%.
Jeśli growthRate jest ujemny to zachodzi analogiczny mechanizm dla decline. Jeśli overallProgress spadnie poniżej 0% odejmowany jest 1 punkt z wszystkich atrybutów, a overallProgress ma wtedy 99%.

---

## Kontuzje

### Typy

| Typ | Czas trwania | Wpływ |
| --- | ------------ | ----- |
| **Minor** | ~ 1–42 dni | niedostępność; bez spadku potencjału |
| **Major** | ~ 43–365 dni | długa absencja; możliwy spadek potencjału (szczegóły powyżej w temacie potencjał) |

### Lista kontuzji

Kontuzje dzielą się na kilka grup anatomicznych i mogą mieć różny czas trwania, od kilku dni do wielu miesięcy. Część urazów blokuje zawodnika także przez protokoły medyczne, a nie tylko sam ból lub ograniczenie ruchu.

#### Głowa i twarz

| Kontuzja | Typ | Zakres trwania (dni) | Opis |
| --- | --- | --- | --- |
| Wstrząśnienie mózgu | Minor | 3–14 | blokuje zawodnika z powodów protokołów medycznych |
| Rozcięta głowa | Minor | 0–3 | lekki uraz, często leczony plastrem w trakcie meczu |
| Rozcięty łuk brwiowy | Minor | 0–3 | lekki uraz, często leczony plastrem w trakcie meczu |
| Złamana szczęka | Minor | 30–60 | poważny uraz twarzoczaszki |
| Złamany nos | Minor | 3–14 | możliwy szybki powrót do gry w masce ochronnej |
| Złamana kość policzkowa | Minor | 14–42 | zwykle wymaga przerwy lub operacji |

#### Ramiona i klatka piersiowa

| Kontuzja | Typ | Zakres trwania (dni) | Opis |
| --- | --- | --- | --- |
| Wybity bark | Minor | 21–42 | bolesna kontuzja ograniczająca kontakt i pracę rękami |
| Złamany obojczyk | Minor | 30–60 | uniemożliwia treningi i grę kontaktową |
| Stłuczenie żeber | Minor | 7–20 | utrudnia oddychanie i kontakt fizyczny |
| Złamanie żeber | Minor | 20–40 | utrudnia oddychanie i kontakt fizyczny |
| Naciągnięcie mięśni klatki piersiowej | Minor | 3–14 | krótki, drobny uraz |

#### Mięśnie nóg

| Kontuzja | Typ | Zakres trwania (dni) | Opis |
| --- | --- | --- | --- |
| Naciągnięcie mięśnia dwugłowego uda (hamstring) | Minor | 14–42 | klasyczna kontuzja sprinterska |
| Zerwanie mięśnia dwugłowego uda (hamstring) | Major | 60–90 | ciężki uraz wymagający długiej rehabilitacji |
| Naderwanie mięśnia czworogłowego uda | Minor | 14–56 | podobny charakter do hamstringa, często odnawia się przy zbyt wczesnym powrocie |
| Uraz pachwiny | Minor | 7–90 | od lekkiego przeciążenia do zerwania, skłonność do nawrotów |
| Naciągnięcie łydki | Minor | 14–30 | wyklucza zawodnika na okres od kilku do kilkunastu dni |
| Naderwanie łydki | Minor | 25–42 | wyklucza zawodnika na okres od kilku do kilkunastu dni |

#### Stawy: kolana

| Kontuzja | Typ | Zakres trwania (dni) | Opis |
| --- | --- | --- | --- |
| Zerwanie więzadeł krzyżowych (ACL) | Major | 180–300 | najgroźniejsza kontuzja, drastycznie obniża możliwości fizyczne |
| Uszkodzenie więzadeł pobocznych (MCL / LCL) | Major | 50–90 | lżejsze niż ACL, ale nadal poważne |
| Uszkodzenie łąkotki | Major | 50–70 | zwykle wymaga operacji i rehabilitacji |
| Skręcenie kolana | Minor | 14–28 | ogólny uraz tkanki miękkiej |

#### Stawy: kostki i stopy

| Kontuzja | Typ | Zakres trwania (dni) | Opis |
| --- | --- | --- | --- |
| Skręcenie stawu skokowego | Minor | 3–42 | bardzo powszechny uraz |
| Zerwanie ścięgna Achillesa | Major | 50–180 | bardzo ciężki uraz |
| Złamanie kości śródstopia | Major | 60–90 | klasyczny uraz mechaniczny |
| Złamany palec u nogi | Minor | 14–21 | uciążliwy, ale zwykle krótszy uraz |
| Stłuczenie stopy | Minor | 3–7 | lekki uraz meczowy |

### Rozkład prawdopodobieństwa

| Kontuzja                                        | Typ   | Prawdopodobieństwo |
| ----------------------------------------------- | ----- | ------------------ |
| Skręcenie stawu skokowego                       | Minor | 7,00%              |
| Skręcenie kolana                                | Minor | 6,50%              |
| Naciągnięcie mięśnia dwugłowego uda (hamstring) | Minor | 5,80%              |
| Uraz pachwiny                                   | Minor | 5,20%              |
| Rozcięta głowa                                  | Minor | 4,40%              |
| Stłuczenie żeber                                | Minor | 4,30%              |
| Naderwanie mięśnia czworogłowego uda            | Minor | 4,30%              |
| Naciągnięcie łydki                              | Minor | 4,20%              |
| Złamany nos                                     | Minor | 3,60%              |
| Złamanie żeber                                  | Minor | 3,60%              |
| Naderwanie łydki                                | Minor | 3,60%              |
| Stłuczenie stopy                                | Minor | 3,40%              |
| Wstrząśnienie mózgu                             | Minor | 2,90%              |
| Złamana szczęka                                 | Minor | 2,90%              |
| Złamana kość policzkowa                         | Minor | 2,90%              |
| Wybity bark                                     | Minor | 2,90%              |
| Złamany obojczyk                                | Minor | 2,90%              |
| Naciągnięcie mięśni klatki piersiowej           | Minor | 2,90%              |
| Złamany palec u nogi                            | Minor | 2,90%              |
| Zerwanie mięśnia dwugłowego uda (hamstring)     | Major | 2,40%              |
| Uszkodzenie więzadeł pobocznych (MCL / LCL)     | Major | 2,60%              |
| Złamanie kości śródstopia                       | Major | 3,20%              |
| Uszkodzenie łąkotki                             | Major | 3,20%              |
| Zerwanie ścięgna Achillesa                      | Major | 3,80%              |
| Zerwanie więzadeł krzyżowych (ACL)              | Major | 4,80%              |

### Przebieg kontuzji

Po zdiagnozowaniu kontuzji określane jest ile dni potrzebnych jest do powrotu do zdrowia. W trakcie trwania kontuzji gracz nie może przebywać w składzie meczowym oraz ma clamp (minValue, 0) na growthRate (zawodnik nie może się rozwinąć, ale jeśli ma ujemny growthRate to OVR może spadać)

### Inne czynniki

- `injuryProne` wpływa na częstotliwość urazów.
- Niska stamina zwiększa ryzyko kontuzji.
- `professional` obniża szansę urazu.
- Major injury może dodatkowo obniżyć potencjał zawodnika.
- Zakresy trwania są orientacyjne i mogą być modulowane przez losowość oraz kontekst meczu lub treningu.

## Eventy losowe

Poniższe eventy dotyczą **indywidualnie zawodnika** — jego rozwoju, formy, zdrowia i sytuacji osobistej. Generują wiadomość w inboksie. Eventy decyzyjne czekają na reakcję gracza; AI rozwiązuje je automatycznie wg profilu (`AI_behaviour.md`).

---

### Przełom w formie (Breakthrough)

**Aktywacja:** zawodnik w wieku ≤26, `overallProgress` ≥ 70%, forma ≥ 8 utrzymana przez 4+ tygodnie. Szansa rolla: 8%/tydzień w tym stanie. Cooldown: 1 na sezon per zawodnik.

- **Automatyczny (brak decyzji gracza):** `growthRate` +0,3 na 6 tygodni. Komunikat fabularny: „X przechodzi okres intensywnego rozwoju".

---

### Upadek formy (Cold Streak)

**Aktywacja:** forma spadła do ≤3 i utrzymuje się 3+ tygodnie. Szansa rolla: 12%/tydzień w tym stanie. Nie dotyczy graczy `professional`.

- **Rozmowa motywująca (Accept):** 60% szans na +2 formy natychmiast; 40% szans na brak efektu; musi być wystawiony w pierwszym składzie w kolejnym meczu.
- **Odesłanie na ławkę (Decline):** forma clampowana do minimum 2 (nie spada dalej) na 2 tygodnie, ale zawodnik traci −0,1 growthRate na 4 tygodnie i nie może być wystawiony w pierwszym składzie w kolejnym meczu.

---

### Powrót po kontuzji — komplikacje

**Aktywacja:** zawodnik wraca z kontuzji typu Major (pierwszy tydzień po zakończeniu rehabilitacji). Szansa rolla: 15%.

- **Ostrożny powrót (Accept — ograniczasz minuty):** zawodnik niedostępny przez dodatkowe 7–14 dni, ale gwarantuje pełne wyzdrowienie (brak dalszych efektów).
- **Pełne obciążenie (Decline — wracasz od razu):** 25% szansy na nawrót kontuzji (ten sam typ, 30-50% oryginalnego czasu trwania). Jeśli nawrotu nie ma — brak konsekwencji.

---

### Spadek motywacji (weteran)

**Aktywacja:** wiek ≥ 32, `seasonsWithTeam` ≥ 4, drużyna w dolnej połowie tabeli. Szansa rolla: 5%/tydzień. Nie dotyczy graczy `professional` ani `leader`.

- **Automatyczny:** growthRate −0,2 na 4 tygodnie, forma −1 jednorazowo. Komunikat: „X wydaje się tracić zapał".
- **Powierzenie roli mentora (Accept — jeśli gracz otrzyma event):** neguje karę growthRate; zamiast tego +0,1 growthRate dla jednego losowego gracza w wieku ≤23 w rosterze na 4 tygodnie. Wymaga: gracz ma `determination` ≥ 6.

---

### Zaangażowanie w trening (Extra Sessions)

**Aktywacja:** zawodnik z `determination` ≥ 7, forma ≥ 6, brak kontuzji. Szansa rolla: 4%/tydzień. Cooldown: 3 miesiące per zawodnik.

- **Zezwolenie (Accept):** `growthRate` +0,2 na 4 tygodnie, ale stamina −5/tydzień przez ten okres (dodatkowe obciążenie). Ryzyko kontuzji ×1,15 w tym okresie.
- **Odmowa (Decline — chronisz przed kontuzją):** brak efektu. Jeśli zawodnik `ambitious`: −1 forma jednorazowo (frustracja).

---

### Problemy osobiste

**Aktywacja:** losowy event niezależny od stanu gracza. Szansa: 0,5%/tydzień per zawodnik. Gracze `professional` mają szansę zmniejszoną do 0,2%.

- **Automatyczny:** forma −2, growthRate −0,15 na 3 tygodnie. Komunikat: „X zmaga się z problemami poza boiskiem".
- **Wsparcie klubu (Accept — pojawia się jako follow-up po 1 tygodniu; 20% szansy):** skraca efekt do 1 tygodnia (zamiast 3). Bez dodatkowych kosztów.
- **Brak reakcji:** efekt trwa pełne 3 tygodnie.

---

### Nagły skok fizyczności (Late Bloomer)

**Aktywacja:** zawodnik w wieku 22–26, `overallProgress` < 30%. Szansa rolla: 3%/tydzień w offseason do 1 tygodnia nowego sezonu. Jednorazowy per zawodnik (raz w karierze).

- **Automatyczny:** jednorazowo +2 do atrybutu `physicality` (outfield) lub `speed` (GK). Komunikat fabularny: „X przeszedł fizyczną metamorfozę w okresie przygotowawczym".

---

### Odnowienie kontuzji (Recurring Injury)

**Aktywacja:** zawodnik miał kontuzję Major w ciągu ostatnich 12 miesięcy, `injuryProne` ≥ 7. Szansa: 3%/tydzień. Cooldown: 1 rok.

- **Automatyczny:** kontuzja Minor tej samej grupy anatomicznej co oryginalna Major (losowy czas z zakresu Minor dla danej grupy). Komunikat: „X odczuwa dyskomfort w miejscu dawnej kontuzji".

---

### Inspirujący występ (Man of the Match spark)

**Aktywacja:** zawodnik uzyskał najwyższy `matchRating` w meczu i rating ≥ 8.0. Szansa rolla: 3% po takim meczu.

- **Automatyczny:** forma +1, `overallProgress` +5% jednorazowo. Czysto pozytywny event.

---