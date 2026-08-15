# Trades

## Co można wymieniać

- Kontrakty zawodników.
- Prawa do zawodników, np. wydraftowany gracz z draftu z niepodpisanym jeszcze kontraktem
- **Picki draftowe** (1.–3. runda) — własne lub nabyte wcześniej

## Dopasowanie pensji (salary matching)

- Drużyna **poniżej salary cap:** może przyjąć kontrakt(y) bez dopasowania do wysyłanych pensji (musi mieć wolne cap space).
- Drużyna **powyżej cap, poniżej 1st apron:** może „wchłonąć” do **125%** wysłanych pensji + stały bufor matchingowy (**500 000**) — to limit dopasowania pensji, nie transfer gotówki.
- Drużyna **między 1st a 2nd apron:** matching jak powyżej, ale **bez agregacji** wielu kontraktów na jednego zawodnika w jednej transakcji.
- Drużyna **powyżej 2nd apron:** nie może **zwiększyć** łącznej pensji w wymianie; może tylko obniżyć payroll lub wymienić 1:1 w ramach dopasowania bez netto wzrostu.

## Reguła Stepiena (picki 1. rundy)

- Drużyna **nie może** oddać picków **1. rundy w dwóch kolejnych latach**, jeśli nie posiada już picka 1. rundy w którymś z tych lat.
- W praktyce: musisz zostawić sobie co najmniej jeden pick 1. rundy co drugi rok draftu (chroni przed „wyczyszczeniem” przyszłości klubu).

## Limity assetów w transakcji

- W jednej wymianie można przekazać maks. **3 picki**
- Można handlować pickami maks. **7 lat** do przodu (do +7 edycji draftu)
- Można wymienić maksymalnie **5** swoich zawodników

## Klauzule i ograniczenia zawodników

- Po wymianie **Bird rights nie przechodzą automatycznie**: `seasonsWithTeam` = **0**, `hasBirdRights` = **false** w nowym klubie — staż i Bird trzeba **odbudować**.

### No-trade clause (NTC)

Zawodnik z aktywną NTC musi **wyrazić zgodę** na wymianę do konkretnego klubu.

#### Próg uprawnienia

Wszystkie warunki muszą być spełnione **jednocześnie**, w momencie podpisania lub przedłużenia kontraktu:

| Warunek | Wartość |
| ------- | ------- |
| Wiek | **≥ 30** lat |
| `seasonsWithTeam` | **≥ 4** pełne sezony bez przerwy |
| `pointValue` | **≥ 200** |
| Długość podpisywanego kontraktu | **≥ 2** lata |

#### Roll przyznania (20%)

Spełnienie progu **nie oznacza** automatycznej NTC — nie każdy weteran o to zabiega.

| Zdarzenie | Prawdopodobieństwo |
| --------- | -----------------: |
| Zawodnik spełniający próg występuje o NTC przy podpisaniu / przedłużeniu | **20%** |
| Zawodnik nie spełniający próg | **0%** |

- Roll wykonywany **raz**, w momencie finalizacji kontraktu. Wynik jest widoczny w UI od razu po podpisie.
- Klub **nie może** odmówić przyznania NTC — jest to element warunków, na które zawodnik się zgodził.
- NTC obowiązuje do **końca kontraktu**, w ramach którego została przyznana. Nie przechodzi na kolejne przedłużenie — przy przedłużeniu wykonywany jest nowy roll.
- Po wymianie NTC **wygasa**: `seasonsWithTeam` = 0 zeruje próg uprawnienia, więc w nowym klubie zawodnik musi odbudować staż.

#### Działanie przy wymianie

Zgoda rolowana **po** przejściu walidacji cap / roster / Stepien, ale **przed** wykonaniem transakcji.

```text
P(zgoda) = 55% + statusModifier + contextModifier
```

| `statusModifier` — `teamStatus` klubu docelowego vs obecnego | Wartość |
| ----------------------------------------------------------- | ------: |
| Wyższy (np. `retool` → `contender`) | **+20 pp** |
| Taki sam | **0** |
| Niższy (np. `contender` → `rebuild`) | **−15 pp** |

| `contextModifier` | Wartość |
| ----------------- | ------: |
| Zawodnik ma zaakceptowaną prośbę o transfer (`team_management.md`) | **+30 pp** |
| Osobowość `loyal` | **−15 pp** |
| Osobowość `ambitious` i klub docelowy wyżej w tabeli siły | **+10 pp** |
| Atmosfera obecnego klubu < 40 | **+10 pp** |

Clamp: `P(zgoda) ∈ [10%, 95%]`.

#### Skutki odmowy

| Skutek | Reguła |
| ------ | ------ |
| Transakcja | anulowana w całości — żaden asset nie zmienia klubu |
| Atmosfera / zgranie | **bez zmian** (odmowa nie jest konfliktem) |
| Blokada | **30 dni** na ponowną próbę wymiany **tego zawodnika do tego samego klubu** |
| Inne kluby | brak blokady — można próbować od razu z innym partnerem |
| Wiadomość | typ `trade`, priorytet `urgent` (`messages.md`) |

Odmowa jest widoczna dla obu stron wymiany. AI traktuje NTC jako obniżenie wyceny assetu (`AI_behaviour.md` §2.3).

## Wymagania formalne

- Wymiany wyłącznie **między dwiema drużynami**
- Standardowo każda strona musi spełniać limity rosteru po wymianie: **20–30** zawodników. **Brak** wymogu liczby bramkarzy.
- **Wyjątek — drużyna poniżej 20 zawodników:** jeśli jedna ze stron ma roster **< 20** zawodników, może zsubmitować trade tylko pod warunkiem, że po wymianie jej roster będzie **liczniejszy niż przed wymianą** (nie musi od razu osiągnąć 20 — liczy się sam wzrost liczby zawodników). Druga strona wymiany musi mimo to pozostać w standardowym limicie **20–30**.
- Jeśli **obie** strony wymiany mają roster poniżej 20 zawodników, trade między nimi jest **niedozwolony** — nie może zostać zsubmitowany, niezależnie od tego, jak rozłożone byłyby transferowane assety.
- Poza opisanym wyjątkiem: jeśli którakolwiek strona wyszłaby poza 20–30, trade nie może być **zsubmitowany**.
- Transakcja musi przechodzić walidację **cap / apron** dla obu uczestników.

## Ograniczenia przy apronach (skrót)

| Poziom                         | Skutek dla wymian                                                                            |
| ------------------------------ | -------------------------------------------------------------------------------------------- |
| Poniżej cap                    | Pełna elastyczność w ramach cap space                                                        |
| Powyżej cap, poniżej 1st apron | Matching 125%; agregacja dozwolona                                                           |
| 1st apron – 2nd apron          | Brak agregacji                                                                               |
| Powyżej 2nd apron              | Brak netto wzrostu pensji; brak picków 1. rundy w pakiecie „dokupionym”                      |

## Wymiany z AI

Każda oferta ma swoje assety i ich łączną wartość pointValue. Na jej podstawie zapada decyzja, czy AI zgadza się na trade. Więcej szczegółów w `AI_behaviour.md`.

## Po wymianie

- `seasonsWithTeam` = 0; Bird rights w nowym klubie trzeba odbudować
- Reset stażu wpływa też na zgranie (szczegóły w `team_management.md`)
- Statystyki sezonowe pozostają przy zawodniku
- Wycena w UI wymian opiera się m.in. o `pointValue` zawodnika (`player_management.md`).