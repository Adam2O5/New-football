# Draft zawodników

## Struktura draftu

- **30 drużyn** — każda ma początkowo (picki mogą później zostać wymienione) po **1 picku w każdej rundzie** (łącznie **90 wyborów**).
- **3 rundy** draftu.
- Pula talentów (**draft class**) liczy domyślnie **120 prospektów**.
- 30 niewybranych ląduje w Free Agency.


## Kto uczestniczy w loterii

- Do loterii **1. rundy** kwalifikuje się **10 najsłabszych drużyn** ligi, po 5 z każdej konferencji (drużyny spoza play-in/playoff).
- Pozostałe **20 drużyn** otrzymują picki **11–30** w **kolejności odwrotnej do miejsca w tabeli** (1. miejsce → pick #30).

### Loteria 1. rundy (ważone szanse)

Wzorowana na NBA: każda z **10** drużyn ma wagę szans na **kolejny** wolny pick (losowanie bez zwracania). Kolejność ustalana na podstawie odwrotnej kolejności tabeli całej ligi.


| Miejsce wśród 10 (od najgorszego) | Waga |
| -------------------------------- | ---- |
| 1–3                              | 140  |
| 4                                | 125  |
| 5                                | 105  |
| 6                                | 90   |
| 7                                | 75   |
| 8                                | 60   |
| 9                                | 45   |
| 10                               | 30   |


- Najgorszy rekord ma **najwyższą** szansę na wczesny pick, ale **nie ma gwarancji** picka #1.
- Po loterii do kolejności dołączane są picki **11–30** według odwrotnej kolejności tabeli całej ligi.


### Kolejność picków w rundach 2 i 3

- **Runda 1:** loteria (1–10) + picki 11–30 według odwrotnej kolejności tabeli.
- **Runda 2 i 3:** **odwrócona** kolejność z tabeli całej ligi — 1. miejsce → ostatni pick rundy (#60/#90).


### Pula prospektów (draft class)

- Prospekci generowani **zaraz po zakończeniu draftu** poprzedniej edycji (klasa na rok N+1).
- Seed / nowa kariera: pierwsza klasa generowana przy starcie save’a (przed pierwszym draftem) + od razu mock wstępny.
- **Wiek:** 18–20 lat.
- **Pozycje:** losowe z puli.
- **Narodowość:** imię i nazwisko z puli kraju.
- Odkryte są bazowe dane zawodników: imię, nazwisko, wiek, narodowość i pozycja.
- Atrybuty bazowe / potencjał maleją wraz z true rankem klasy.

### Dwa mock drafty

Oba ustalają **kolejność wyświetlania** (nie kolejność picków klubów). True board = ukryty ranking jakości klasy.

#### True Board

Posortowana lista po potencjale i OVR (po wartości potencjał * OVR).

#### Mock wstępny (po generacji klasy)

- Moment: wieczór **poniedziałku tyg. 46** (po drafcie) — dla klasy N+1. (lub dzień pierwszy save'a)
- Większa wariancja true rank → displayed rank:

| True projected band | Typowy zakres odchylenia |
| ------------------- | ------------------------ |
| Top / wczesna R1 | ± **10–15** miejsc |
| Środek boardu | ± **15–22** |
| Projected R3 / undrafted | ± **25–30** |


#### Mock finalny (piątek tyg. 45)

Ustala kolejność tabeli prospectów w drafcie. 

| True projected band | Typowy zakres odchylenia |
| ------------------- | ------------------------ |
| Top / wczesna R1 | ± **5–10** miejsc |
| Środek boardu | ± **12–20** |
| Projected R3 / undrafted | ± **25–30** |

## Draft

Kolejność wyboru drużyn jest ustalana w lottery. Kolejność wyboru jest przypisywana do konkretnych picków, nie drużyn - po wymianie picków kolejność wyboru drużyn się zmienia. Każdy pick oznacza wybór jednego gracza. Draft kończy się gdy wszystkie drużyny zrealizują wszystkie 90 picków draftu.

### Po drafcie

- Historia: `draftPicks`.
- Generacja klasy N+1 + mock wstępny.
