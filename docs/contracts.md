# Podpisywanie kontraktów (extensions, FA, sztab)

---

## 1. Zakres

| Okno | Kiedy | Kogo dotyczy |
| ---- | ----- | ------------ |
| **Contract extensions** | wt–niedz tyg. **46** (10h/dzień) | Własni zawodnicy (Bird) + **sztab** (wolni / wygasający) |
| **Free agency (phase I)** | pon tyg. **47** → niedziela tyg. **47** | UFA/RFA, niedraftowani, sztab FA |
| **Free agency (phase II)** | pon tyg. **48** → **niedziela tyg. 45** kolejnego cyklu | UFA/RFA pozostali z fazy I, sztab FA |

### Kolejność okien w cyklu rocznym

Okna **nie nakładają się**. Pełny cykl:

```text
tyg. 46 pon        → Draft (draft.md)
tyg. 46 wt–niedz   → Contract extensions
tyg. 47 pon–niedz  → Free agency phase I (10h/dzień)
tyg. 48 pon        → Free agency phase II — start
   ...
tyg. 45 niedziela  → Free agency phase II — koniec
tyg. 46 pon        → Draft (nowy cykl)
```

- FA phase II **kończy się w niedzielę tyg. 45**, czyli dzień przed draftem i trzy dni przed startem okna przedłużeń.
- Między niedzielą tyg. 45 a wtorkiem tyg. 46 **żadne okno kontraktowe nie jest otwarte** — to bufor na draft.
- W trakcie fazy II obowiązują wszystkie pozostałe eventy kalendarza (sezon, playoff, offseason) — faza II biegnie w tle przez cały rok poza wymienionymi wyjątkami.
- Negocjacja rozpoczęta w fazie II i niezakończona do niedzieli tyg. 45 zostaje **anulowana** (brak `hard reject`); podmiot wraca do puli FA i można go zaczepić ponownie w fazie I.

---

## 2. Contract extensions

Obejmuje zarówno staff i zawodników. Możliwość składania ofert
w ekranie contracts_screen. Każdy dzień ma 10 godzin. W każdej godzinie
można złożyć jedną ofertę zawodnikowi i jedną ofertę członkowi sztabu.
Po zakończeniu godziny 10 dzień automatycznie przechodzi do następnego.
W przypadku braku przedłużenia kontraktu staff staje się free agentem,
a zawodnicy w zależności od swojego kontraktu stają się RFA/UFA.

---

## 3. FA (phase I)

Obejmuje zarówno staff i zawodników. Możliwość składania ofert 
w ekranie free_agency_screen. Model dnia oparty na ostatnim dniu okienka transferowego z gier FIFA. Odpowiedź (wstępna) od wolnych agentów w ciągu godziny.

```text
godzina = 1 … 10
klik „symuluj godzinę” → +1h
w każdej godzinie: gracz może złożyć 1 ofertę za zawodnika i 1 za staff
AI klubów składają oferty w tej samej godzinie (1 zawodnik, 1 staff / klub / h)
```

- Niezużyta godzina = strata slotu oferty.
- Po 10h: koniec dnia kalendarzowego i przejście do kolejnego.

---

## 4. FA (phase II)

Obejmuje zarówno staff i zawodników. Możliwość składania ofert 
w ekranie free_agency_screen. Składanie ofert bez limitu ilościowego.
Odpowiedź (wstępna) od wolnych agentów w ciągu 2 - 4 dni.

---

## 5. Reakcje na ofertę (wspólne)

| Reakcja | Znaczenie |
| ------- | --------- |
| **Accept** | kontrakt gotowy do potwierdzenia |
| **Hard reject** | koniec rozmów z tym klubem przez 30 dni |
| **Reject** | odrzucenie oferty bez większych konsekwencji |
| **Waiting** | czeka na inne oferty |
| **Counter** | kontrpropozycja |

**Accept**:
- zawodnik/członek sztabu akceptuje warunki umowy i czeka na finalne potwierdzenie transakcji 
(w phase I 3 godziny albo do końca dnia; w phase II 3 dni; w contract extension 1 dzień)
- w przypadku braku finalizacji transakcji i upłynięcia czasu na potwierdzenie zawodnik przechodzi w reakcję **hard reject**, co uniemożliwia kolejne natychmiastowe negocjacje

**Hard reject**:
- w przypadku przedstawienia oferty na znacznie zaniżonym poziomie następuje **hard reject**

**Waiting**:
- reakcja wyłącznie dla FA (phase I)
- aktywacja reakcji (według priorytetu zdarzeń):
  - aktywuje się jeśli gracz otrzymał kilka ofert w tą samą godzinę, wtedy waiting do przed ostatniej godziny dnia -> decyzja i finalizacja w ostatnią godzinę
  - aktywuje sie gdy gracz otrzymał tylko jedną ofertę i jest ona poniżej oczekiwanej wartości, wtedy waiting do przed ostatniej godziny dnia -> decyzja i finalizacja w ostatnią godzinę
  - aktywuje się zawsze na 2 godziny (lub do przedostatniej godziny) -> decyzja w trzeciej godzinie (lub ostatniej godzinie), chyba że w ciągu 2 godzin podmiot otrzyma ofertę, wtedy waiting do przed ostatniej godziny dnia -> decyzja i finalizacja w ostatnią godzinę
- jeśli nastąpi aktywacja np. w przedostatnią godzinę to decyzja zawsze jest podejmowana w ostatnią godzinę (finalizacja też konieczna przed końcem dnia)
- jeśli zespół złoży ofertę za gracza/staff, ale podmiot wybierze ofertę innego zespołu i nie dojdzie do finalizacji to **nie** następuje **hard reject**

**Counter**:
- w przypadku decyzji negatywnej podmiotu oferty (ale nie **hard reject**) i bliskiej wartości oczekiwanej oferty może nastąpić counter offer ze strony podmiotu
- gdy następuje w przedostatnią godzinę FA (phase I), wtedy przedstawiana jest informacja o "zastanawianiu się zawodnika" do końca dnia, a w kolejnym dniu w pierwszej godzinie następuje przedstawienie kontroferty do wszystkich zainteresowanych
- zaakceptowanie kontroferty to natychmiastowa akceptacja, która nie wymaga potwierdzenia finalizacji
- jeśli więcej niż jeden zespół zaakceptuje kontrofertę to wtedy podmiot decyduje którą ofertę wybiera i od razu ją finalizuje
- user może odrzucić kontrofertę i złożyć kontr-kontrofertę (szczegóły w Counter details)

---

## 6. Zawodnicy 

### Model wymagań (`playerWant`)

```text
playerWant = clamp(((point_value + 1000) / 20) + personalityFactor + currentTeamStatus, 0, 100)
```

| Składnik | Zakres | Źródło |
| -------- | ------ | ------ |
| `(point_value + 1000) / 20` | 0 … 100 | `pointValue` z `player_management.md` |
| `personalityFactor` | −4 … +5 | tabela poniżej |
| `currentTeamStatus` | −5 … +7 | `team_management.md` — Team status |

Clamp końcowy: `playerWant ∈ [0, 100]`.

#### personalityFactor

Osobowość przesuwa oczekiwania kontraktowe zawodnika. Wartość dodatnia = **wyższe** wymagania (wyższa oczekiwana pensja i dłuższy kontrakt).

| Osobowość | `personalityFactor` | Charakter negocjacji |
| --------- | ------------------: | -------------------- |
| `ambitious` | **+5** | maksymalizuje stawkę, traktuje pensję jako potwierdzenie statusu |
| `temperamental` | **+4** | trudny w rozmowach, podbija oczekiwania ponad wartość rynkową |
| `leader` | **+1** | świadomy swojej roli, ale nie wyciska ostatniego euro |
| `balanced` | **0** | baseline, brak modyfikatora |
| `professional` | **−2** | podejście zawodowe, mniejszy nacisk na warunki finansowe |
| `loyal` | **−4** | przywiązanie do klubu ważniejsze niż stawka |

Rozkład jest spójny z resztą modelu: `loyal` nie składa prośby o transfer (`team_management.md`) i jednocześnie najtaniej przedłuża kontrakt; `ambitious` jest odwrotnością na obu wymiarach.

> `currentTeamStatus` w `playerWant` działa **w tym samym kierunku** co w `offerScore`: w mocnym klubie zawodnik oczekuje stawki adekwatnej do poziomu zespołu (`+7` przy `elite`), w klubie w odbudowie godzi się na mniej (`−5` przy `rebuild`). Atrakcyjność samego klubu jest osobno premiowana w `playerOfferScore`.

### Oczekiwana pensja

Na podstawie wartości playerWant obliczana jest oczekiwana wartość kontraktu.

```text
expectedSalary(playerWant) = minSalary + (maxSalary − minSalary) × (playerWant / 100)^3
minSalary = salary_cap.md
maxSalary = salary_cap.md
```

### Oczekiwana długość kontraktu

Na podstawie playerWant i wieku obliczana jest oczekiwana długość kontraktu.

| Wiek \ `playerWant` | Niskie (0–39) | Średnie (40–69) | Wysokie (70–100) |
| --- | --- | --- | --- |
| `<= 23` | 2 lata | 3 lata | 4 lata |
| 24–29 | 2 lata | 3 lata | 5 lat |
| 30–32 | 1 rok | 2 lata | 3 lata |
| 33+ | 1 rok | 1 rok | 2 lata |

### Model atrakcyjności oferty (`playerOfferScore`)

```text
playerOfferScore ∈ [0, 100]

initial formula (can be changed)
playerOfferScore = (salaryFit + lengthFit + teamStatus) * cfoDiscount

salaryFit - poniżej
lengthFit - poniżej
teamStatus - poniżej
cfoDiscount - staff.md
```
### PlayerOfferScore values

Poniższe dane liczbowe to startowe dane liczbowe, które mogą ulec zmianie.

#### SalaryFit

Wartość oparta na procentowym odchyleniu od oczekiwanej pensji. Default wartość to 35.
Za każdy procent mniej wartość salaryFit spada o 2, a za każdy procent więcej wartość wzrasta o 1.

#### LengthFit

Wartość oparta na odchyleniu od oczekiwanej długości kontraktu. Default wartość to 15.
Każdy rok odchylenia zmniejsza wartość o 5.

#### TeamStatus

Wartość oparta na obecnym teamStatus:
- rebuild - -5
- retool - -3
- pretender - 0
- contender - 5
- elite - 7

#### PlayerOfferScore threshold

| playerOfferScore | Decyzja                                     | Znaczenie                                                                                                      |
| ---------- | ------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| 0–24       | Hard reject                                 | Oferta wyraźnie poniżej oczekiwań. Kończy rozmowy na standardowy okres blokady.                                |
| 25–39      | Reject zależnie od kontekstu                | Oferta za słaba, ale jeszcze nie skrajnie zła.                                                                 |
| 40–54      | Counter                                     | Oferta bliska akceptacji, ale wymaga poprawy. Podmiot może złożyć kontrofertę.                                 |
| 55–69      | Waiting / Counter / Accept                  | Oferta wystarczająca. Waiting w FA phase I zastępuje Accept. W innych fazach losowa decyzja, czy Accept, czy Counter.            |
| 70–100     | Accept                                      | Oferta dobra. Zawsze prowadzi do akceptacji.                                                                   |

W zakresie 55-69 losowanie decyzji jest zdefinowane tak:
- w środku przedziału (62) szanse są 50/50
- każdy jeden punkt odchylenia zmienia rozkład szans o 6 punkty (z jednej strony odejmuje się 3 i dodaje 3 do drugiej), np. przy 65 jest Counter 41 - 59 Accept

#### Counter details

- po każdej kontrofercie user może złożyć swoją kontr-kontrofertę
- counter offer przedstawia pierwszą ofertę w zakresie 65 - 100, drugą w zakresie 65 - 85 i trzecią w zakresie 60 - 70
- czwarta kontroferta nie następuje 
- przy decyzji kontr-kontroferty jest szansa na **hard reject** (przy pierwszej 15%, drugiej 30%, trzeciej 50% i dodatkowo 0% szans na counter, więc na dobrą sprawę 50/50 czy accept czy hard reject przy trzeciej decyzji)

### Contract Extension

Szczegółowa reguła minutowa znajduje się w sekcji „Reguła minut przy extension” na końcu dokumentu.

### FA

- jeśli gracz otrzyma oferty z kilku klubów to wybiera tą z lepszym playerOfferScore 

---

## 7. Staff 

### Model wymagań (`staffWant`)

```text
staffWant = clamp(roleStarsAvg × 20 + currentTeamStatus, 0, 100)
```

| Składnik | Zakres | Źródło |
| -------- | ------ | ------ |
| `roleStarsAvg` | 0,5 … 5,0 ★ | średnia gwiazdek atrybutów istotnych dla danej roli (`staff.md`) |
| `× 20` | skalowanie ★ → 10 … 100 | — |
| `currentTeamStatus` | −5 … +7 | `team_management.md` — Team status |

Clamp końcowy: `staffWant ∈ [0, 100]`.

Sztab nie ma osobowości, więc nie występuje tu odpowiednik `personalityFactor`.

### Oczekiwana pensja

Na podstawie wartości staffWant obliczana jest oczekiwana wartość kontraktu. 

```text
expectedSalary(staffWant) = minSalary + (maxSalary - minSalary) × (staffWant / 100)^2
minSalary = salary_cap.md
maxSalary = salary_cap.md
```

### Oczekiwana długość kontraktu

Na podstawie staffWant i wieku obliczana jest oczekiwana długość kontraktu.

| Wiek \ `staffWant` | Niskie (0–39) | Średnie (40–69) | Wysokie (70–100) |
| --- | --- | --- | --- |
| 35–44 | 2 lata | 3 lata | 4 lata |
| 45–54 | 2 lata | 3 lata | 4 lata |
| 55–59 | 1 rok | 2 lata | 2 lata |
| 60 | 1 rok | 1 rok | 1 rok |

### Model atrakcyjności oferty (`staffOfferScore`)

```text
staffOfferScore ∈ [0, 100]

initial formula (can be changed)
staffOfferScore = (salaryFit + lengthFit + teamStatus) * cfoDiscount

salaryFit - poniżej
lengthFit - poniżej
teamStatus - poniżej
cfoDiscount - staff.md
```
### StaffOfferScore values

Poniższe dane liczbowe to startowe dane liczbowe, które mogą ulec zmianie.

#### SalaryFit

Wartość oparta na procentowym odchyleniu od oczekiwanej pensji. Default wartość to 35.
Za każdy procent mniej wartość salaryFit spada o 2, a za każdy procent więcej wartość wzrasta o 1.

#### LengthFit

Wartość oparta na odchyleniu od oczekiwanej długości kontraktu. Default wartość to 15.
Każdy rok odchylenia zmniejsza wartość o 5.

#### TeamStatus

Wartość oparta na obecnym teamStatus:
- rebuild - -5
- retool - -3
- pretender - 0
- contender - 5
- elite - 7

#### StaffOfferScore threshold

| staffOfferScore | Decyzja                                     | Znaczenie                                                                                                      |
| ---------- | ------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| 0–24       | Hard reject                                 | Oferta wyraźnie poniżej oczekiwań. Kończy rozmowy na standardowy okres blokady.                                |
| 25–39      | Reject zależnie od kontekstu                | Oferta za słaba, ale jeszcze nie skrajnie zła.                                                                 |
| 40–59      | Counter                                     | Oferta bliska akceptacji, ale wymaga poprawy. Podmiot może złożyć kontrofertę.                                 |
| 55–69      | Waiting / Counter / Accept                  | Oferta wystarczająca. Waiting w FA phase I zastępuje Accept. W innych fazach losowa decyzja, czy Accept, czy Counter.            |
| 70–100     | Accept                                      | Oferta dobra. Zawsze prowadzi do akceptacji.                                                                   |

W zakresie 55-69 losowanie decyzji jest zdefinowane tak:
- w środku przedziału (62) szanse są 50/50
- każdy jeden punkt odchylenia zmienia rozkład szans o 6 punkty (z jednej strony odejmuje się 3 i dodaje 3 do drugiej), np. przy 65 jest Counter 41 - 59 Accept

#### Counter details

- po każdej kontrofercie user może złożyć swoją kontr-kontrofertę
- counter offer przedstawia pierwszą ofertę w zakresie 65 - 100, drugą w zakresie 65 - 85 i trzecią w zakresie 60 - 70
- czwarta kontroferta nie następuje 
- przy decyzji kontr-kontroferty jest szansa na **hard reject** (przy pierwszej 15%, drugiej 30%, trzeciej 50% i dodatkowo 0% szans na counter, więc na dobrą sprawę 50/50 czy accept czy hard reject przy trzeciej decyzji)

### FA

- jeśli gracz otrzyma oferty z kilku klubów to wybiera tą z lepszym staffOfferScore 

---

## 8. Extension exceptions

Wyjątki od standardowej walidacji cap/staff cap przy przedłużeniach i podpisach.

| Exception | Warunek aktywacji | Limit | Max lata | Okno |
| --- | --- | --- | --- | --- |
| Rookie Scale | Kontrakt z wydraftowanym zawodnikiem | `baseScale / (1 + pickSlot × 0,06)` | 2 lata | Contract extension |
| Rookie Extension | Zawodnik w 2. (ostatnim) roku rookie scale. | Dowolna wartość, ale klub ma wyłączność negocjacji. | 5 lat | Contract extension |
| Qualifying Offer / RFA | Rookie scale wygasł, klub złożył `QO >= 1,25 × ostatnia pensja rookie` | Inne kluby: offer sheet w ramach własnego cap; klub macierzysty: match do identycznych warunków. | 5 lat | FA phase I |
| Full Bird Rights | `seasonsWithTeam >= 3` bez przerwy (bez tradu/FA w międzyczasie). | Podpis powyżej cap, do `maxSalary`. | 5 lat | Contract extension |
| Early Bird Rights | `seasonsWithTeam = 2` | Podpis powyżej cap, max `175%` ostatniej pensji lub `60% maxSalary`, zależnie co niższe. | 4 lata | Contract extension |
| Non-Bird Rights | `seasonsWithTeam < 2` | Podpis powyżej cap, max `120%` ostatniej pensji. | 4 lata | Extension |
| Veteran Extension Raise Cap | Przedłużenie zawodnika spoza rookie scale. | Pensja roku 1 `<=` poprzednia pensja × `1,08` (max `8%` podwyżki r/r na etapie oferty startowej). | — | Contract extension |

baseScale - 8 000 000
maxSalary - salary_cap.md

### Uwagi

- RFA/UFA rozróżnienie: brak QO → zawodnik staje się UFA i trafia bezpośrednio do puli FA bez prawa match dla klubu macierzystego.
- Klub macierzysty bez QO konkuruje na równi z innymi, poza ewentualnym Bird rights, jeśli je posiada.
- Okno na match w RFA odpowiada oknu finalizacji `Accept` z §5:
  - FA phase I — 3h lub do końca dnia.
  - FA phase II — 3 dni.

## 9. Inne szczegóły

- user nie może podpisać kontraktu z kolejnym graczem, jeśli ma już w rosterze 30 graczy
- kontrakt dla wydraftowanego zawodnika może, lecz nie musi zostać zaoferowany. Jeśli klub nie zaoferuje kontraktu to gracz dalej jest assetem zespołu, nie liczy się do limitu graczy, ale też nie może grać. User może w każdym momencie podpisać takiego zawodnika, jeśli jest miejsce w rosterze lub wytradeować jako asset - drużyna otrzymująca prawa do gracza nie musi mieć miejsca w rosterze w trakcie wymiany, dopiero w momencie podpisu musi je mieć (analogicznie jak dla poprzedniej drużyny). Zasady kontraktowe działają tak jak w momencie podpisu w trakcie contract extension (długość kontraktu taka sama).

---

### Utrwalony lifecycle negocjacji

User i AI korzystają ze wspólnego `LeagueState.negotiations` i modelu `ContractNegotiation`. Rekord przechowuje podmiot, klub, fazę, rundę, ostatnią ofertę, reakcję, deadline i stan terminalny. Dzięki temu restart lub przejście przez kolejną godzinę nie tworzy osobnego, ulotnego stanu AI.

`Waiting` jest zapisany w negocjacji wraz z terminem i jest rozstrzygany przez hourly resolver; deadline nie jest rekonstruowany wyłącznie z bieżącej godziny. `Accept` przechodzi do `pendingFinalization` z terminem właściwym dla fazy, a brak finalizacji wygasza negocjację zgodnie z regułami §5. Negocjacja rozstrzygnięta w bieżącym slocie jest pomijana przez ten sam tick podczas wygaszania, aby nowa decyzja nie została natychmiast zastąpiona przez hard reject.

### Reguła minut przy extension

Zawodnik ocenia przedłużenie na podstawie minut z całego bieżącego sezonu, obejmującego sezon regularny, play-in i playoffy. Rynek korzysta z osobnego agregatu `seasonMinutes`; istniejące `minutesHistory` pozostaje sześciotygodniowym oknem używanym przez eventy drużynowe.

```text
actualMinutesShare = sum(actualMinutes) / sum(possibleMinutes)
```

Wpisy z `possibleMinutes = 0` są wyłączone z mianownika. Kontuzja i zawieszenie ustawiają `possibleMinutes = 0`, a walkower nie zapisuje minut w ogóle. Reguła jest oceniana dopiero przy `possibleMinutes >= 1000`; przy mniejszej próbie działa standardowa negocjacja.

OVR używany przez regułę to średnia surowego snapshotu z początku sezonu i bieżącego surowego OVR:

```text
effectiveOvr = (seasonStartRawOvr + currentRawOvr) / 2
```

| Zakres effective OVR | Wymagany actualMinutesShare | Reakcja przy niespełnieniu |
| --- | ---: | --- |
| `>= 87` | `>= 65%` | Hard reject |
| `80–<87` | `>= 50%` | Hard reject |
| `75–<80` | `>= 35%` | Hard reject |
| `70–<75` | `>= 20%` | Hard reject |
| `< 70` | reguła nieaktywna | brak odmowy minutowej |

Niespełnienie aktywnego progu kończy rozmowy jako `hardReject` i tworzy istniejącą blokadę negocjacji na 30 dni. Wiadomość odpowiedzi zawiera `reasonCode` oraz dane OVR, licznika minut i udziału, aby UI mogło wyjaśnić odmowę. Zmiana modelu zapisu podnosi `SaveSchema.currentVersion` do 17.
