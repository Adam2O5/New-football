### Kiedy można handlować

- **Okno wymian:** od **zakończenia playoff** (po niedzieli tyg. **43** / od poniedziałku tyg. **44**) do **trade deadline** (poniedziałek tyg. **23** sezonu regularnego) — `game_calendar.md`.
- Po **trade deadline** zabronione są nowe transakcje do końca playoff (brak wyjątków w v1).

### Co można wymieniać

- Kontrakty zawodników (z pensją, latami i klauzulami).
- **Picki draftowe** (1.–3. runda) — własne lub nabyte wcześniej.
- **Prawa do swapów** picków (np. „lepszy pick z puli drużyn A/B”).

### Dopasowanie pensji (salary matching)

- Drużyna **poniżej salary cap:** może przyjąć kontrakt(y) bez dopasowania do wysyłanych pensji (musi mieć wolne cap space).
- Drużyna **powyżej cap, poniżej 1st apron:** może „wchłonąć” do **125%** wysłanych pensji + stały bufor matchingowy (~**500 tys. €** w skali gry) — to limit dopasowania pensji, nie transfer gotówki.
- Drużyna **między 1st a 2nd apron:** matching jak powyżej, ale **bez agregacji** wielu kontraktów na jednego zawodnika w jednej transakcji (reguła jak w NBA od 2023).
- Drużyna **powyżej 2nd apron:** nie może **zwiększyć** łącznej pensji w wymianie; może tylko obniżyć payroll lub wymienić 1:1 w ramach dopasowania bez netto wzrostu.


### Reguła Stepiena (picki 1. rundy)

- Drużyna **nie może** oddać picków **1. rundy w dwóch kolejnych latach**, jeśli nie posiada już picka 1. rundy w którymś z tych lat.
- W praktyce: musisz zostawić sobie co najmniej jeden pick 1. rundy co drugi rok draftu (chroni przed „wyczyszczeniem” przyszłości klubu).


### Ochrony picków (lottery protections)

- Picki można zabezpieczyć warunkiem: np. „top-4 protected” — jeśli pick wyląduje w loterii w top 4, pozostaje u dotychczasowego właściciela; w przeciwnym razie przechodzi na partnera wymiany.
- Dozwolone są **ladder protections** (top-10 → top-8 → top-5 → unprotected) w wieloletnich układach.


### Limity picków w transakcji

- W jednej wymianie można przekazać maks. **3 picki** (łącznie z swapami liczone jako osobne aktywa).
- Można handlować pickami maks. **7 lat** do przodu (do +7 edycji draftu).
- **Zakaz:** handel pickiem z **1. rundy** z roku, w którym drużyna nie ma jeszcze ustalonej kolejności loterii (przed zamknięciem sezonu regularnego).


### Klauzule i ograniczenia zawodników

- **No-trade clause (NTC):** tylko weterani spełniający próg stażu/lat w lidze — zawodnik musi wyrazić zgodę na transfer do wybranego klubu.
- **Limited no-trade (15% rule):** możliwość wskazania np. 4–8 drużyn, do których **nie** można go wysłać bez zgody.
- Po wymianie **Bird rights nie przechodzą automatycznie**: `seasonsWithTeam` = **0**, `hasBirdRights` = **false** w nowym klubie — staż i Bird trzeba **odbudować** (`salary_cap_rules.md`).


### Traded Player Exception (TPE)

- Jeśli drużyna wyśle zawodnika bez odbioru pensji 1:1 (np. same picki), otrzymuje **TPE** w wysokości wysłanej pensji + bufor matchingowy.
- TPE można użyć w ciągu **1 roku** do pozyskania innego zawodnika bez dopasowania pensji, do kwoty TPE (nie łączy się z innymi exception powyżej cap).


### Wymagania formalne

- Wymiany wyłącznie **między dwiema drużynami** (brak tradów 3+ drużyn — `Może_kiedyś_do_dodania.md`).
- Każda strona musi spełniać limity rosteru po wymianie: **20–30** zawodników (`squad_management.md`). **Brak** wymogu liczby bramkarzy.
- Jeśli którakolwiek strona wyszłaby poza 20–30, trade jest **odrzucany** (nie da się „wypaść” poza limit tradem — tylko emeryturą).
- Transakcja musi przechodzić walidację **cap / apron** dla obu uczestników.


### Ograniczenia przy apronach (skrót)

| Poziom                         | Skutek dla wymian                                                                            |
| ------------------------------ | -------------------------------------------------------------------------------------------- |
| Poniżej cap                    | Pełna elastyczność w ramach cap space                                                        |
| Powyżej cap, poniżej 1st apron | Matching 125% + TPE; agregacja dozwolona                                                     |
| 1st apron – 2nd apron          | Brak agregacji                                                                               |
| Powyżej 2nd apron              | Brak netto wzrostu pensji; brak MLE w wymianie; brak picków 1. rundy w pakiecie „dokupionym” |



### Po wymianie

- `seasonsWithTeam` = 0; Bird rights w nowym klubie trzeba odbudować (≥ 3 sezony lub nowa flaga po przedłużeniu) — `salary_cap_rules.md`.
- Reset stażu wpływa też na zgranie (`squad_management.md`).
- Statystyki sezonowe pozostają przy zawodniku; koszulka / skład aktualizowane od następnego meczu.
- Wycena w UI wymian opiera się m.in. o `pointValue` zawodnika (`player_management.md`).
