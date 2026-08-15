# Model taktyczny

## Formacje

### Lista formacji

Aktualna lista wspieranych formacji odpowiada finalnej liście z enumu `Formation`.
Każda formacja ma trzy bazowe słupki faz gry: `def`, `mid`, `atk`.

| Enum         | Etykieta           | def | mid | atk | Notatka                                                            |
| ------------ | ------------------ | --- | --- | --- | ------------------------------------------------------------------ |
| f343         | 3-4-3              | 42  | 55  | 68  | Bardzo ofensywna szerokość, ryzyko z tyłu.                         |
| f3421        | 3-4-2-1            | 46  | 64  | 60  | Dwóch kreatorów za napastnikiem, lepsza kontrola niż w 3-4-3.      |
| f352         | 3-5-2              | 50  | 70  | 55  | Mocna kontrola środka przy umiarkowanym ataku.                     |
| f3511        | 3-5-1-1            | 49  | 71  | 54  | Jeszcze bardziej środkowa wersja 3-5-2, trochę mniej bezpośrednia. |
| f41212Narrow | 4-1-2-1-2 (narrow) | 56  | 64  | 58  | Diament: balans środka i gry pionowej.                             |
| f4132        | 4-1-3-2            | 53  | 67  | 59  | Mocny środek z dwójką z przodu.                                    |
| f4141        | 4-1-4-1            | 62  | 74  | 42  | Najbardziej kontrolna i defensywna z czwórką z tyłu.               |
| f4231        | 4-2-3-1            | 56  | 68  | 57  | Elastyczny środek i dobra równowaga.                               |
| f4231Wide    | 4-2-3-1 (wide)     | 53  | 62  | 64  | Mniej kontroli, więcej szerokości i wejść w atak.                  |
| f424         | 4-2-4              | 40  | 45  | 75  | Ekstremalny atak kosztem kontroli i obrony.                        |
| f4312        | 4-3-1-2            | 52  | 65  | 61  | Wąski środek z wyraźną obecnością między liniami.                  |
| f4321        | 4-3-2-1            | 54  | 67  | 57  | Kontrola i półprzestrzenie bardziej niż czysta szerokość.          |
| f433         | 4-3-3              | 55  | 60  | 62  | Uniwersalna baza rodziny.                                          |
| f433Attack   | 4-3-3 (attack)     | 50  | 58  | 68  | Wariant bardziej ryzykowny i wertykalny.                           |
| f433Defend   | 4-3-3 (defend)     | 61  | 58  | 55  | Wariant bezpieczniejszy, bardziej zachowawczy.                     |
| f442         | 4-4-2              | 58  | 55  | 60  | Klasyczna równowaga dwóch linii i dwóch napastników.               |
| f442Defend   | 4-4-2 (defend)     | 64  | 56  | 51  | Głębsza, bezpieczniejsza odmiana 4-4-2.                            |
| f451         | 4-5-1              | 60  | 72  | 48  | Gęsty środek i wysoka kontrola, ale mniejsze zagrożenie z przodu.  |
| f5212        | 5-2-1-2            | 70  | 52  | 55  | Niski blok + CAM + dwójka z przodu.                                |
| f523         | 5-2-3              | 68  | 48  | 62  | Trójka z przodu przy pięciu z tyłu.                                |
| f532         | 5-3-2              | 72  | 58  | 52  | Stabilny blok z umiarkowanym wsparciem środka.                     |

### Matchupy formacji

Matchupy są oparte głównie na tej tabeli:

| Id | Rodzina | Formacje |
| -- | ------------------------- | --------------------------------------- |
| 1 | 3-back wide | f343, f3421, f352, f3511 |
| 2 | 4-back wide balanced | f433, f433Attack, f433Defend, f4231Wide |
| 3 | 4-back central control | f4231, f4141, f451, f41212Narrow, f4312 |
| 4 | 4-back direct two-striker | f442, f442Defend, f4132, f424 |
| 5 | 5-back block | f5212, f523, f532 |

Relacje między rodzinami:
- 2, 3 < 1 < 4, 5
- 3, 5 < 2 < 4, 1
- 4, 5 < 3 < 1, 2
- 1, 2 < 4 < 3, 5
- 1, 4 < 5 < 2, 3

| Rodzina A                    | Rodzina B                    | ΔD | ΔM | ΔA | Dlaczego (w skrócie)                                                      |
| ---------------------------- | ---------------------------- | -- | -- | -- | ------------------------------------------------------------------------- |
| 1. 3-back wide               | 2. 4-back wide balanced      | 0  | +1 | +2 | przewaga na flankach daje więcej akcji, środek dość równy.                |
| 1. 3-back wide               | 3. 4-back central control    | -1 | +1 | +2 | atak na przestrzenie za środkiem, lekko gorszy blok z tyłu.               |
| 1. 3-back wide               | 4. 4-back direct two-striker | +1 | 0  | -2 | bezpośredniość rywala w półprzestrzeniach, my ostrożniej.                 |
| 1. 3-back wide               | 5. 5-back block              | +2 | -2 | -3 | trudniej rozciągnąć 5 z tyłu, więc mniej ataku, więcej asekuracji.        |
| 2. 4-back wide balanced      | 3. 4-back central control    | 0  | +1 | +1 | większa szerokość vs wąskie środki, lekka przewaga w ataku i midzie.      |
| 2. 4-back wide balanced      | 4. 4-back direct two-striker | 0  | +1 | +1 | lepsza szerokość vs płaskie 4-4-2 / 4-2-4.                                |
| 2. 4-back wide balanced      | 5. 5-back block              | +1 | -1 | -2 | mało miejsca na skrzydłach, więc mniej ataku, więcej ostrożności.         |
| 3. 4-back central control    | 4. 4-back direct two-striker | -1 | +2 | 0  | kontrola środka i ustawienie między liniami, ale mniej bezpośrednia.      |
| 3. 4-back central control    | 5. 5-back block              | -1 | +2 | 0  | cierpliwa gra i praca w półprzestrzeniach, bez dużej zmiany ataku.        |
| 4. 4-back direct two-striker | 5. 5-back block              | -2 | 0  | +2 | blok kontra overcommit: my bardziej bezpośredni, oni bardziej defensywni. |

Dodatkowe wyjątki dodatnie:

| Formacja A | Formacja B | ΔD | ΔM | ΔA | Dlaczego                                                              |
| ---------- | ---------- | -- | -- | -- | --------------------------------------------------------------------- |
| 4-1-4-1    | 3-4-3      | -1 | +2 | +1 | lepsza kontrola środka i lepszy balans przy zachowaniu ataku.         |
| 4-1-4-1    | 3-4-2-1    | -1 | +2 | 0  | podobnie: więcej kontroli, lekko lepszy atak przez lepsze ustawienie. |
| 4-2-3-1    | 3-5-2      | 0  | +2 | +1 | lepsze wykorzystanie półprzestrzeni i CAM przeciwko 3-5-2.            |
| 4-3-3      | 3-4-1-2    | 0  | +1 | +2 | szerokość 4-3-3 lepiej atakuje przestrzenie za 3-4-1-2.               |
| 4-4-2      | 4-1-2-1-2  | -1 | +1 | +2 | dwie dziewiątki lepiej atakują trójkę z tyłu diamentu.                |
| 4-2-2-2    | 5-3-2      | -1 | +1 | +2 | czwórka z przodu rozciąga 5-back i daje więcej sytuacji.              |
| 5-2-1-2    | 4-3-3      | -1 | +1 | +2 | blok 5 z tyłu + CAM dobrze gra przeciwko 4-3-3.                       |
| 5-3-2      | 4-2-3-1    | -1 | +1 | +2 | solidny blok i dwie dziewiątki przeciwko 4-2-3-1.                     |

Dodatkowe wyjątki ujemne:

| Formacja A | Formacja B | ΔD | ΔM | ΔA | Dlaczego                                                                   |
| ---------- | ---------- | -- | -- | -- | -------------------------------------------------------------------------- |
| 3-4-3      | 4-1-4-1    | +1 | -2 | -1 | 4-1-4-1 dusi środek i ogranicza atak 3-4-3.                                |
| 3-5-2      | 4-1-4-1    | +1 | -2 | -1 | podobnie: 4-1-4-1 wygrywa w środku i ogranicza atak.                       |
| 4-5-1      | 5-3-2      | +1 | -1 | -2 | 5-3-2 lepiej broni i ogranicza atak 4-5-1.                                 |
| 4-2-4      | 5-2-1-2    | +2 | -2 | -3 | 5-2-1-2 świetnie broni przeciwko 4-2-4, my bardzo ofensywnie i ryzykownie. |
| 4-3-3      | 5-2-1-2    | +1 | -1 | -2 | 5-2-1-2 lepiej broni i ogranicza atak 4-3-3.                               |

## Kształt D–M–A

Kształt `D–M–A` nadal istnieje jako pojęcie projektowe i analityczne, ale nie jest już osobnym polem w danych balansu. 

Reguły liczenia pozostają koncepcyjnie takie same:
- **D**: CB + FB/WB ustawieni w linii obrony,
- **M**: CDM + CM + CAM + skrzydłowi ustawieni jako pomocnicy,
- **A**: ST oraz skrzydłowi ustawieni w bloku ofensywnym.

To oznacza, że `D–M–A` jest teraz metryką pochodną, przydatną w UI, balansie i analizie matchupów, ale nie osobnym źródłem prawdy w modelu danych.

## Ustawienia taktyczne

Globalne ustawienia drużyny pozostają osobnym wymiarem taktyki i są przechowywane jako mapy delt w `TacticsBalance`. Każde ustawienie modyfikuje `def`, `mid`, `atk` niezależnie od wybranej formacji.

### Tempo (`Tempo`)

| Wartość | Δ atk | Δ mid | Δ def | Cecha meczowa |
| ------- | ----: | ----: | ----: | ------------- |
| `slow` | -4 | +3 | +2 | Mniej kontr, bezpieczniejsze podania. |
| `balanced` | 0 | +1 | 0 | Wartość neutralna. |
| `fast` | +6 | -2 | -3 | Więcej przejść i strat, wyższe tempo gry. |

### Szerokość ataku (`AttackWidth`)

| Wartość | Δ atk | Δ mid | Δ def | Cecha |
| ------- | ----: | ----: | ----: | ----- |
| `narrow` | -2 | +2 | +1 | Gra przez środek, dobra kontra na szerokie 3-back. |
| `balanced` | 0 | +1 | 0 | Wartość neutralna. |
| `wide` | +4 | -1 | -3 | Więcej pojedynków 1v1 i dośrodkowań, większe ryzyko z tyłu. |

### Linia obrony (`DefensiveLine`)

| Wartość | Δ def | Δ atk | Cecha |
| ------- | ----: | ----: | ----- |
| `deep` | +3 | -3 | Głębszy blok, mniej przestrzeni za plecami. |
| `normal` | 0 | 0 | Wartość neutralna. |
| `high` | -4 | +4 | Agresywniejsze wyjście wyżej, ryzyko piłek za linię. |

### Pressing (`PressingIntensity`)

| Wartość | Δ mid | Δ def | Δ atk | Cecha |
| ------- | ----: | ----: | ----: | ----- |
| `low` | -1 | +3 | -2 | Oszczędza staminę i zmniejsza liczbę fauli. |
| `medium` | 0 | 0 | 0 | Wartość neutralna. |
| `high` | +2 | -3 | +1 | Więcej odzysków wysoko, ale wyższe koszty fizyczne. |
| `gegenpressing` | +3 | -5 | +2 | Maksymalny nacisk po stracie, najwyższe ryzyko zmęczenia i kartek. |

### Stałe fragmenty

Domyślnie 50:
- `cornersAttack`,
- `cornersDefense`,
- `freeKicks`,
- `penalties`. 

Wpływają na eventy SFG, ale nie zmieniają bezpośrednio bazowego `def` / `mid` / `atk` w open play.

### Matchupy taktyczne

#### Tempo vs linia obrony

| Nasze       | Ich            | ΔD | ΔM | ΔA | Dlaczego                                            |
| ----------- | -------------- | -- | -- | -- | --------------------------------------------------- |
| deep line   | fast tempo     | +1 | 0  | 0  | cofnięty blok lepiej broni szybkie ataki.           |
| deep line   | slow tempo     | -1 | 0  | 0  | oddajesz pole i kontrolę wolno budującemu rywalowi. |
| high line   | slow tempo     | 0  | +1 | 0  | możesz wyjść wyżej i mocniej kontrolować mecz.      |
| high line   | fast tempo     | -1 | 0  | -1 | ryzyko piłek za plecy i szybkich kontr.             |
| normal line | balanced tempo | 0  | 0  | 0  | neutralny matchup.                                  |

#### Pressing vs tempo

| Nasze         | Ich           | ΔD | ΔM | ΔA | Dlaczego                                                      |
| ------------- | ------------- | -- | -- | -- | ------------------------------------------------------------- |
| low press     | fast tempo    | 0  | +1 | 0  | rywal sam zwiększa chaos, my lepiej wykorzystujemy przejścia. |
| low press     | gegenpressing | +1 | +1 | 0  | twarda kontra: lepiej bronić i kontrolować przeciwko agresji. |
| high press    | slow tempo    | 0  | +1 | +1 | łatwo docisnąć wolno budującego i zyskać więcej ataków.       |
| gegenpressing | low press     | 0  | +1 | +1 | agresywny pressing przeciwko pasywnej obronie.                |
| gegenpressing | fast tempo    | 0  | -1 | 0  | mecz zbyt losowy, tracimy część kontroli w środku.            |

#### Szerokość ataku vs szerokość rywala

| Nasze  | Ich    | ΔD | ΔM | ΔA | Dlaczego                                                  |
| ------ | ------ | -- | -- | -- | --------------------------------------------------------- |
| wide   | narrow | 0  | 0  | +1 | rozciągasz wąski blok i zyskujesz więcej akcji.           |
| wide   | wide   | 0  | 0  | 0  | neutralizacja skrzydeł.                                   |
| narrow | wide   | 0  | +1 | 0  | zagęszczasz środek, gdy rywal nie ma przewagi centralnej. |
| narrow | narrow | 0  | 0  | 0  | walka o centrum bez wyraźnej kontry.                      |

#### Szerokość ataku vs formacja rywala

| Nasze  | Ich                    | ΔD | ΔM | ΔA | Dlaczego                                                           |
| ------ | ---------------------- | -- | -- | -- | ------------------------------------------------------------------ |
| wide   | 3-back wide            | 0  | 0  | +1 | już sugerowane jako dobre przeciwko szerokim trójkom.              |
| wide   | 5-back block           | +1 | 0  | -1 | 5 z tyłu lepiej broni flank, więc mniej ataku, więcej ostrożności. |
| narrow | 4-4-2 / 4-3-3 (wąskie) | 0  | +1 | 0  | lepsza kontrola środka przeciwko wąskim formacjom.                 |
| narrow | 4-back central control | 0  | -1 | 0  | wchodzisz tam, gdzie rywal jest najmocniejszy w środku.            |

#### Linia obrony vs styl ataku rywala

| Nasze     | Ich                 | ΔD | ΔM | ΔA | Dlaczego                                                          |
| --------- | ------------------- | -- | -- | -- | ----------------------------------------------------------------- |
| deep line | 4-2-4 / 3-4-3       | +1 | 0  | 0  | ograniczasz przestrzeń za plecami przeciwko bardzo ofensywnym.    |
| high line | 5-back block + 1 ST | 0  | 0  | -1 | ryzyko wysokiej linii nie jest opłacalne, gdy rywal mało atakuje. |

## Role pozycji

Każda pozycja ma role (`enums.dart`) i role nadal przesuwają wkład faz gry, ale nie zmieniają `overall`. Obowiązuje zasada, że defensywne role wzmacniają `def`, kreatywne i wertykalne wzmacniają `mid` lub `atk`, a słaby fit roli obniża efektywność zawodnika.

### Delta ról

Role pozycji przesuwają bazowy balans formacji o niewielkie wartości `def`, `mid`, `atk`. Kierunki tych zmian są zgodne z założeniem projektu: role defensywne wzmacniają blok, role kreatywne poprawiają kontrolę i rozegranie, a role ofensywne zwiększają zagrożenie pod bramką kosztem stabilności.

#### `GkRole`

| Rola | Δ def | Δ mid | Δ atk | Notatka |
| --- | ---: | ---: | ---: | --- |
| `standard` | 0 | 0 | 0 | Klasyczny bramkarz bez dodatkowego przesunięcia balansu. |
| `sweeperKeeper` | -1 | +2 | 0 | Pomaga w rozegraniu i ustawieniu wyżej, ale daje trochę mniej bezpieczeństwa klasycznego bloku. |

#### `CbRole`

| Rola | Δ def | Δ mid | Δ atk | Notatka |
| --- | ---: | ---: | ---: | --- |
| `standard` | 0 | 0 | 0 | Uniwersalny środkowy obrońca. |
| `ballPlayingDefender` | -1 | +2 | 0 | Poprawia wyprowadzenie piłki i pierwszą fazę budowy akcji. |
| `noNonsenseCentreBack` | +3 | -3 | 0 | Maksymalizuje bezpieczeństwo i prostotę gry kosztem rozegrania. |

#### `FullBackRole`

| Rola | Δ def | Δ mid | Δ atk | Notatka |
| --- | ---: | ---: | ---: | --- |
| `standard` | 0 | 0 | 0 | Zbalansowany boczny obrońca. |
| `defensiveFullBack` | +3 | -1 | -2 | Gra głębiej i lepiej zabezpiecza flankę. |
| `attackingFullBack` | -2 | +1 | +1 | Wspiera atak i szerokość, ale osłabia stabilność po stracie. |

#### `WingBackRole`

| Rola | Δ def | Δ mid | Δ atk | Notatka |
| --- | ---: | ---: | ---: | --- |
| `standard` | 0 | 0 | 0 | Zbalansowany wahadłowy. |
| `wingBack` | -2 | 0 | +2 | Daje intensywność na boku i większe wsparcie akcji ofensywnych. |
| `invertedWingBack` | -1 | +2 | -1 | Schodzi do środka, poprawia kontrolę i budowanie przewagi w centrum. |

#### `CdmRole`

| Rola | Δ def | Δ mid | Δ atk | Notatka |
| --- | ---: | ---: | ---: | --- |
| `standard` | 0 | 0 | 0 | Klasyczny defensywny pomocnik. |
| `regista` | -1 | +2 | -1 | Najmocniej podbija kontrolę tempa i jakość pierwszego podania. |
| `deepLyingPlaymaker` | -1 | +3 | -1 | Bardziej zachowawcza wersja kreatora z głębi pola. |
| `anchorMan` | +4 | -1 | -3 | Najmocniej wzmacnia ochronę strefy przed obroną kosztem progresji do przodu. |

#### `CmRole`

| Rola | Δ def | Δ mid | Δ atk | Notatka |
| --- | ---: | ---: | ---: | --- |
| `standard` | 0 | +1 | 0 | Uniwersalny środkowy pomocnik. |
| `ballWinning` | +2 | 0 | -1 | Wzmacnia odbiór i pressing bardziej niż kreację. |
| `playmaker` | -1 | +3 | -1 | Poprawia kontrolę piłki i jakość podań progresywnych. |
| `boxToBox` | +1 | -1 | +1 | Najbardziej wszechstronny profil środka pola. |
| `mezzala` | -2 | +1 | +2 | Mocniej atakuje półprzestrzenie i wspiera wejścia w ostatnią tercję. |

#### `CamRole`

| Rola | Δ def | Δ mid | Δ atk | Notatka |
| --- | ---: | ---: | ---: | --- |
| `standard` | 0 | 0 | 0 | Klasyczny łącznik między liniami. |
| `playmaker` | -1 | +2 | -1 | Wzmacnia kreację, rytm i ostatnie podanie. |
| `shadowStriker` | -2 | -1 | +3 | Drugi napastnik z wejściami w pole karne i większym naciskiem na finalizację. |

#### `WingerRole`

| Rola | Δ def | Δ mid | Δ atk | Notatka |
| --- | ---: | ---: | ---: | --- |
| `standard` | 0 | 0 | 0 | Zbalansowany skrzydłowy. |
| `invertedWinger` | 0 | +1 | -1 | Częściej schodzi do środka i kończy akcje strzałem. |
| `winger` | 0 | -1 | +1 | Utrzymuje szerokość i wspiera atak przez drybling oraz dośrodkowania. |

#### `StrikerRole`

| Rola | Δ def | Δ mid | Δ atk | Notatka |
| --- | ---: | ---: | ---: | --- |
| `standard` | 0 | 0 | 0 | Klasyczny napastnik skupiony na wykończeniu. |
| `falseNine` | 0 | +3 | -2 | Cofa się do rozegrania i tworzy przestrzeń dla innych. |
| `deepLyingForward` | 0 | -2 | +3 | Łączy linie i wspiera progresję bez pełnego zejścia jak false nine. |
| `pressingForward` | +2 | 0 | -1 | Daje więcej nacisku z przodu i odzysków wysoko. |
| `completeForward` | -1 | +1 | +1 | Wszechstronny napastnik z mocnym wpływem na kreację i finalizację. |

#### Matchupy ról

| Nasza rola                         | Ich styl / formacja                                           | ΔD | ΔM | ΔA | Dlaczego                                                                          |
| ---------------------------------- | ------------------------------------------------------------- | -- | -- | -- | --------------------------------------------------------------------------------- |
| noNonsenseCentreBack (CB)          | 4-2-4 / 3-4-3 (dużo prostych ataków, dośrodkowań)             | +1 | 0  | 0  | czyste wyclearowanie i minimalizacja ryzyka w polu karnym.                        |
| defensiveFullBack (FB)             | wide atak + attackingFullBack / wingBack po przeciwnej flance | +1 | 0  | 0  | lepiej radzi sobie z 1v1 i nie daje się wyciągnąć tak wysoko.                     |
| anchorMan (CDM)                    | shadowStriker / completeForward grający między liniami        | +1 | 0  | 0  | mocno ogranicza przestrzeń dla drugiego napastnika / CAM.                         |
| ballPlayingDefender (CB)           | low press + deep line rywala                                  | 0  | +1 | 0  | lepsze wyprowadzenie piłki pomaga przełamać niski blok.                           |
| regista / deepLyingPlaymaker (CDM) | high press + high line                                        | 0  | +1 | 0  | szybsze podania i zmiana kierunku gry wykorzystują przestrzeń za pressingu.       |
| playmaker (CM / CAM)               | narrow blok 4-5-1 / 4-1-4-1                                   | 0  | +1 | 0  | lepsze podania w półprzestrzenie i między linie.                                  |
| invertedWingBack (WB)              | narrow środek rywala (4-1-2-1-2, 4-3-1-2)                     | 0  | +1 | 0  | dodatkowa osoba w środku pomaga przejąć kontrolę.                                 |
| shadowStriker (CAM)                | high line + wide obrona                                       | 0  | 0  | +1 | wejścia w pole karne z drugiej linii znajdują luki między CB a FB.                |
| invertedWinger (W)                 | attackingFullBack / wingBack po przeciwnej flance             | 0  | 0  | +1 | atakowanie półprzestrzeni tam, gdzie boczny obrońca rywala jest wysoki.           |
| falseNine (ST)                     | noNonsenseCentreBack + deep line                              | 0  | +1 | 0  | cofanie się wyciąga CB z linii i otwiera przestrzeń dla skrzydłowych / CAM.       |
| pressingForward (ST)               | ballPlayingDefender + regista w wyjściu z tyłu                | 0  | 0  | +1 | pressing na rozgrywających wymusza błędy i straty blisko bramki.                  |
| completeForward (ST)               | 5-back block                                                  | 0  | 0  | +1 | uniwersalność pomaga w przełamywaniu zwartego bloku (gra tyłem + wejścia w pole). |
| attackingFullBack (FB)             | fast tempo + wide atak rywala                                 | -1 | 0  | 0  | zostawiony na szybkie kontrataki swoją wysoką pozycją.                            |
| sweeperKeeper (GK)                 | fast tempo + dużo prostych piłek za linię                     | 0  | -1 | 0  | większe ryzyko przy wyjściach poza linię.                                         |
| ballPlayingDefender (CB)           | gegenpressing rywala                                          | 0  | -1 | 0  | próby rozegrania pod wysokim pressingu zwiększają liczbę strat.                   |
| regista (CDM)                      | gegenpressing + high press                                    | 0  | -1 | 0  | kreator z głębi pola jest mocno atakowany i częściej traci piłkę.                 |

## Składanie końcowego balansu

Balans taktyczny drużyny przed meczem upraszcza się do modelu:

```text
def' = formation.def + tacticsΔ.def + rolesΔ.def + Σ ΔD(formacja vs formacja) + Σ ΔD(taktyka vs taktyka/formacja) + Σ ΔD(rola vs styl)
mid' = formation.mid + tacticsΔ.mid + rolesΔ.mid + Σ ΔM(formacja vs formacja) + Σ ΔM(taktyka vs taktyka/formacja) + Σ ΔM(rola vs styl)
atk' = formation.atk + tacticsΔ.atk + rolesΔ.atk + Σ ΔA(formacja vs formacja) + Σ ΔA(taktyka vs taktyka/formacja) + Σ ΔA(rola vs styl)
```

Aktualnie nie jest przewidziane ograniczanie wartości (clamp) do konkretnych zakresów.