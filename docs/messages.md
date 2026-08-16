# Wiadomości i day-to-day (inbox)

Dokument projektowy: system wiadomości, symulacja dzień-po-dniu oraz tryb godzinowy w oknie kontraktów — w stylu **FIFA 15 Career Mode**.

Powiązane: `game_calendar.md`, `offseason.md`, `contracts.md`, `staff.md`, `matchday_model.md`, `squad_management.md`, `team_management.md`, `player_management.md`, `trades.md`, `draft.md`, `salary_cap.md`, `AI_behaviour.md`.

Status: **kanon reguł**.

---

## 1. Idea

Główne źródło informacji dla gracza to **inbox wiadomości**. Nie ma rozproszonych popup-ów, alertów ani notyfikacji poza inboxem.

- Każde istotne wydarzenie silnika generuje wiadomość.
- Symulacja dzień po dniu; przycisk „symuluj" → natychmiastowe przejście do następnego dnia.
- Wiadomości dostarczane **raz na dzień, na początku dnia** — przed jakąkolwiek akcją gracza.
- Wyjątek: okna kontraktów (`contracts.md`) działają w trybie **godzinowym** (10 godzin na dzień).
- Mecze i eventy dnia odbywają się **na koniec dnia**, po czym następuje przejście do kolejnego dnia.

---

## 2. Przepływ dnia — tryb standardowy

```text
Poniedziałek:
  1. Dostarczenie wszystkich wiadomości za ten dzień (cały pakiet naraz)
  2. Jeśli jest wiadomość `urgent` → PAUZA, inbox otwarty, wymagane acknowledge
  3. Gracz czyta / reaguje / ustawia skład / dokonuje zmian
  4. [Symuluj] →
     a). Jeśli jest event dnia (mecz, lottery, draft itp.) → event na koniec dnia
     b). Jeśli nie ma eventu → natychmiastowe przejście do następnego dnia
  5. Następny dzień → powtórz od 1.
```

**Brak rozróżnienia godzinowego** w trybie standardowym. Wiadomości nie przychodzą w trakcie dnia — cały pakiet trafia na start.

### Tryb godzinowy (FA phase I + Contract extensions)

Aktywuje się wyłącznie w dwóch okienkach (`contracts.md`):
- **Contract extensions:** wt–niedz tyg. 46
- **FA phase I:** pon–niedz tyg. 47

```text
Godzina 1:
  1. Dostarczenie wiadomości za tę godzinę
  2. Jeśli `urgent` → PAUZA
  3. Gracz składa ofertę / reaguje na counter/accept
  4. [Symuluj godzinę] → +1h
  ...
Godzina 10:
  → koniec dnia kalendarzowego → następny dzień
```

- 10 godzin = 1 dzień.
- W każdej godzinie gracz i AI mogą złożyć po 1 ofercie (zawodnik + staff) — `contracts.md` §3.
- Niezużyta godzina = strata slotu oferty.
- Poza tymi dwoma oknami: **zawsze tryb standardowy** (1 dzień = 1 klik).

---

## 3. Kiedy odbywa się event / mecz

| Typ dnia | Zachowanie |
| -------- | ---------- |
| Dzień bez eventu i meczu | Wiadomości → [Symuluj] → natychmiast następny dzień |
| Dzień z meczem | Wiadomości → [Symuluj] → mecz na koniec dnia → wynik + efekty pomeczowe → następny dzień |
| Dzień z eventem (lottery, draft, combine itp.) | Wiadomości → [Symuluj] → event na koniec dnia → następny dzień |
| Dzień z meczem + eventem | Event zawsze **przed** meczem (np. raport scouta rano, mecz wieczorem) |

Mecze i eventy nigdy nie są przerywane wiadomościami — wiadomości wynikające z meczu (injury, matchResult) trafiają do **następnego dnia**.

---

## 4. Model danych wiadomości

| Pole | Typ | Opis |
| ---- | --- | ---- |
| `id` | uuid | unikalny identyfikator |
| `type` | enum | stabilny identyfikator wzorca (np. `injury`, `tradeOffer`) |
| `kind` | enum? | dyskryminator dla typów złożonych (np. `contractOfferResponse.counter`) |
| `domain` | enum | grupa do konfiguracji i filtrów UI |
| `priority` | `silenced` / `normal` / `urgent` | wynikowy: default → eskalacja → config gracza |
| `seasonYear` | int | — |
| `week` | int | numer tygodnia sezonu (`game_calendar.md`) |
| `day` | int | dzień tygodnia (1–7) |
| `hour` | int? | tylko w trybie godzinowym FA/extensions (1–10) |
| `titleKey` | string | klucz z `.arb` |
| `bodyKey` | string | klucz z `.arb` |
| `args` | Map<String, dynamic> | nazwane placeholdery do l10n |
| `payload` | typed refs | `playerId`, `teamId`, `tradeOfferId`, `negotiationId`, `prospectId`, `matchId` — zależne od typu |
| `actions` | List<MessageAction> | CTA: nawigacja lub decyzja |
| `decision` | DecisionSpec? | opcje + `defaultOnExpiry` — tylko przy wiadomościach decyzyjnych |
| `expiresAt` | DateTime? | termin na reakcję (wiadomości decyzyjne) |
| `groupKey` | string? | kubełek digestu |
| `dedupKey` | string? | zwijanie duplikatów |
| `read` | bool | przeczytana |
| `acknowledged` | bool | potwierdzona — wymagane tylko przy `urgent` |

---

## 5. Trzy kategorie

| Kategoria | Zachowanie | W inboksie | Pauza symulacji | Badge |
| --------- | ---------- | ---------- | --------------- | ----- |
| `silenced` | tylko log historii | **nie** | nie | nie |
| `normal` | wpis w inboksie | tak | nie | nieprzeczytane |
| `urgent` | czerwona flaga | tak (przypięta) | **tak** | czerwona flaga |

### Reguły `urgent`

- Wstrzymuje przejście do następnego dnia / następnej godziny.
- Gracz **musi** acknowledge (przeczytanie + dismiss lub podjęcie decyzji).
- Nie wolno kliknąć „Symuluj" z niepotwierdzonym `urgent` w inboksie.
- Wiadomości decyzyjne z terminem (`expiresAt`) są **zawsze** `urgent`.

### Konfiguracja gracza

Gracz ustawia per `type` (lub per `domain` grupowo):

| Ustawienie | Efekt |
| ---------- | ----- |
| **Ważne** | wymusza `urgent` niezależnie od domyślnej kategorii |
| **Normalne** | wymusza `normal` |
| **Wyciszone** | wymusza `silenced` |
| **Auto** (domyślne) | system decyduje wg tabel poniżej |

Nie można wyciszyć wiadomości decyzyjnych — zawsze `urgent` niezależnie od konfiguracji. System nie pozwala zignorować decyzji z terminem.

### Eskalacja warunkowa (przy ustawieniu Auto)

```text
priority = escalate(defaultPriority, predicates)
```

| Predykat | Efekt |
| -------- | ----- |
| Zawodnik w XI | `injury`, `suspensionStart`, `playerEvent.recurringInjury` → `urgent` |
| Kontuzja typu Major | `injury` → `urgent` |
| Nagroda / emerytura dotyczy własnego klubu | `award`, `retirementPlayer` → `urgent` |
| Podmiot spoza własnego klubu (digest ligowy) | o jeden poziom niżej |
| Payroll powyżej 2nd apron | `apronWarning` → `urgent` |
| Brak GK w rosterze | `rosterWarning` → `urgent` |

---

## 6. Konwencja kluczy l10n

Wszystkie teksty wiadomości trafiają do `app_pl.arb` / `app_en.arb` (`general_rules.md`). Zero literałów tekstowych w logice.

```text
msg_<type>_title                       // np. msg_injury_title
msg_<type>_<kind>_title                // np. msg_contractOfferResponse_counter_title
msg_<type>_body
msg_<type>_<kind>_body
msg_<type>_action_<slug>               // np. msg_tradeOffer_action_accept
msg_<type>_digest_title                // np. msg_draftPickLeague_digest_title
msg_<type>_digest_body
```

`args` to nazwane placeholdery ICU MessageFormat: `{playerName}`, `{days}`, `{salary, number, currency}`, `{position}`, `{teamName}` itd.

---

## 7. Wzorzec wiadomości — struktura pojedynczego wpisu

Każdy wzorzec w katalogu (§8) definiuje:

```text
type:            stabilna nazwa enum
kind:            opcjonalny dyskryminator
domain:          domena (matchday / health / playerEvent / teamEvent / roster / contracts / staff / trades / draft / finance / season / system)
defaultPriority: silenced / normal / urgent
escalateIf:      lista predykatów podnoszących priorytet
titleKey:        klucz + komentarz z przykładowym tekstem
bodyKey:         klucz + komentarz
args:            lista nazwanych placeholderów
payload:         lista refów
actions:         lista CTA
decision:        opcje + defaultOnExpiry (jeśli decyzyjna)
expiresAt:       formuła terminu (jeśli decyzyjna)
groupKey:        kubełek digestu (jeśli agregowalna)
dedupKey:        klucz deduplikacji
```

---

## 8. Katalog wzorców

### A. Matchday (7 wzorców)

| type | kind | default | escalate | title (przykład) | body (przykład) | decision |
| ---- | ---- | ------- | -------- | ---------------- | --------------- | -------- |
| `matchPreview` | — | normal | — | „Mecz: {homeTeam} vs {awayTeam}" | „{day}, tyg. {week}. Pogoda: {weather}, {tempC}°C." | — |
| `matchResult` | — | normal | finale/eliminacja → urgent | „Wynik: {homeTeam} {homeGoals}:{awayGoals} {awayTeam}" | „Posiadanie {posA}%–{posB}%. xG {xgA}–{xgB}. MotM: {motm}." | — |
| `walkover` | — | **urgent** | — | „Walkower: {team} 0–3" | „Nielegalny roster ({reason}). Atmosfera −15." | — |
| `lineupNoGk` | — | **urgent** | — | „Brak bramkarza w XI!" | „{team} przystępuje do meczu bez GK. Oczekiwany wynik ~0–5." | — |
| `benchIncomplete` | — | normal | — | „Niepełna ławka: {count}/7" | „{missingCount} miejsc pustych z powodu kontuzji/zawieszeń." | — |
| `suspensionStart` | — | normal | XI → urgent | „Zawieszenie: {playerName}" | „{playerName} pauzuje {games} mecz(e). Powód: {reason}." | — |
| `suspensionEnd` | — | silenced | — | „Powrót: {playerName}" | „{playerName} dostępny po odbyciu zawieszenia." | — |

### B. Zdrowie (4 wzorce)

| type | kind | default | escalate | title | body | decision |
| ---- | ---- | ------- | -------- | ----- | ---- | -------- |
| `injury` | — | normal | XI lub Major → urgent | „Kontuzja: {playerName}" | „{injuryName} ({injuryType}). Absencja ~{days} dni, powrót ~{returnDate}." | — |
| `injuryReturn` | — | normal | — | „Powrót: {playerName}" | „{playerName} wraca do dyspozycji po {injuryName}." | — |
| `injuryRecurrence` | — | normal | XI → urgent | „Nawrót kontuzji: {playerName}" | „{playerName} odczuwa dyskomfort — {injuryName} ({days} dni)." | — |
| `potentialLoss` | — | normal | — | „Spadek potencjału: {playerName}" | „Potencjał obniżony o 0,5★ (skutek Major: {injuryName})." | — |

### C. Eventy zawodnika — `playerEvent` (11 kinds)

Wszystkie generują wiadomość w inboksie (`player_management.md`).

#### Decyzyjne (urgent)

| kind | title | body | decision options | defaultOnExpiry | expiresAt |
| ---- | ----- | ---- | ---------------- | --------------- | --------- |
| `plateau` | „Plateau: {playerName}" | „Brak przyrostu OVR od 8 tyg. Zmiana programu treningowego?" | Accept / Decline | Decline | +2 dni |
| `coldStreak` | „Kryzys formy: {playerName}" | „Forma ≤3 od 3 tyg. Rozmowa motywująca czy ławka?" | Accept (rozmowa) / Decline (ławka) | Decline | +1 dzień |
| `injuryComplication` | „Komplikacje: {playerName}" | „Powrót po Major — ostrożnie (+{extraDays}d) czy pełne obciążenie?" | Ostrożny / Pełny | Pełny | +1 dzień |
| `veteranMotivation` | „Spadek motywacji: {playerName}" | „{playerName} traci zapał. Powierzyć rolę mentora?" | Mentor / Ignoruj | Ignoruj | +2 dni |
| `extraTraining` | „Dodatkowe treningi: {playerName}" | „{playerName} chce extra sesji. Zezwolić (ryzyko kontuzji)?" | Zezwól / Odmów | Odmów | +1 dzień |
| `personalSupport` | „Wsparcie: {playerName}" | „{playerName} zmaga się z problemami. Zapewnić wsparcie klubu?" | Wsparcie / Ignoruj | Ignoruj | +3 dni (follow-up po 1 tyg.) |

#### Automatyczne (normal)

| kind | title | body |
| ---- | ----- | ---- |
| `breakthrough` | „Przełom: {playerName}" | „Intensywny rozwój — growthRate +0,3 na 6 tyg." |
| `personalProblems` | „Problemy osobiste: {playerName}" | „Forma −2, growthRate −0,15 na 3 tyg." |
| `lateBloomer` | „Fizyczna metamorfoza: {playerName}" | „+2 do {attribute} jednorazowo." |
| `nationalTeam` | „Kadra: {playerName}" | „Powołany na zgrupowanie. Forma +1, stamina −15." |
| `inspiredPerformance` | „Inspirujący występ: {playerName}" | „MotM — progress +5%, forma +1." |

### D. Eventy zespołu — `teamEvent` (9 kinds)

#### Decyzyjne (urgent)

| kind | title | body | decision options | defaultOnExpiry | expiresAt |
| ---- | ----- | ---- | ---------------- | --------------- | --------- |
| `moreMinutesRequest` | „Prośba o minuty: {playerName}" | „{playerName} chce więcej minut ({reason})." | Accept / Decline | Decline (= Ignoruj) | koniec dnia |
| `transferRequestI` | „Prośba o transfer: {playerName}" | „{playerName} chce odejść ({reason})." | Accept / Decline | Decline | koniec dnia |
| `transferRequestII` | „Żądanie transferu: {playerName}" | „{playerName} domaga się odejścia po {trigger}." | Accept / Decline | Decline | koniec dnia |
| `dressingRoomConflict` | „Konflikt w szatni" | „≥2 zawodników temperamental i atmosfera <40." | Interwencja / Ignoruj | Ignoruj | koniec dnia |
| `publicCriticism` | „Publiczna krytyka: {playerName}" | „{playerName} krytykuje menedżera publicznie." | Odpowiedź / Kara / Ignoruj | Ignoruj | koniec dnia |

#### Automatyczne

| kind | default | title | body |
| ---- | ------- | ----- | ---- |
| `declineToExtend` | normal | „Brak przedłużenia: {playerName}" | „{playerName} deklaruje brak chęci przedłużenia umowy." |
| `leaderSupport` | normal | „Lider wspiera: {playerName}" | „{playerName} motywuje zespół. Atmosfera +4, zgranie +1." |
| `promiseBroken` | urgent | „Złamana obietnica: {playerName}" | „Obiecane minuty nie zostały dostarczone. Atmosfera −12." |
| `atmosphereShift` | normal | „Zmiana atmosfery" | „Atmosfera: {oldLevel} → {newLevel} ({delta})." |

### E. Roster (4 wzorce)

| type | default | escalate | title | body | decision |
| ---- | ------- | -------- | ----- | ---- | -------- |
| `rosterBelowMin` | **urgent** | — | „Roster poniżej minimum!" | „{count}/20 zawodników. Uzupełnij przez FA / wymianę." | — |
| `rosterAtMax` | normal | — | „Roster pełny: 30/30" | „Podpisanie kolejnego zawodnika wymaga wymiany." | — |
| `retirementPlayer` | normal | własny → urgent | „Emerytura: {playerName}" | „{playerName} ({age}) kończy karierę. Cap space +{salary}." | — |
| `retirementLeagueDigest` | silenced | — | „Emerytury w lidze" | „{count} zawodników przeszło na emeryturę." | — |

### F. Kontrakty (10 wzorców)

| type | kind | default | title | body | decision |
| ---- | ---- | ------- | ----- | ---- | -------- |
| `contractOfferResponse` | `accept` | **urgent** | „Akceptacja: {subjectName}" | „Czeka na finalizację ({timeLeft})." | Finalizuj / Anuluj |
| `contractOfferResponse` | `reject` | normal | „Odrzucenie: {subjectName}" | „Oferta odrzucona. Można ponawiać." | — |
| `contractOfferResponse` | `hardReject` | **urgent** | „Twarde odrzucenie: {subjectName}" | „Blokada rozmów na 30 dni." | — |
| `contractOfferResponse` | `waiting` | normal | „Czeka: {subjectName}" | „Rozważa oferty — decyzja {decisionTime}." | — |
| `contractOfferResponse` | `counter` | **urgent** | „Kontroferta: {subjectName}" | „Oczekuje {salary}/rok na {years} lat. Runda {round}/3." | Accept / Counter / Decline |
| `contractSigned` | — | normal | „Podpis: {subjectName}" | „{subjectName} → {teamName}, {salary}/rok, {years} lat." | — |
| `contractExpiring` | — | normal | — | „{playerName} — kontrakt wygasa po sezonie." | — |
| `contractLostToRival` | — | normal | „Stracony cel: {subjectName}" | „{subjectName} podpisał z {rivalTeam}." | — |
| `rfaQualifyingOffer` | — | **urgent** | „QO do złożenia: {playerName}" | „Termin na Qualifying Offer: {deadline}." | Złóż QO / Rezygnuj |
| `rfaOfferSheet` | — | **urgent** | „Offer sheet: {playerName}" | „{rivalTeam} złożył offer sheet. Match? ({timeLeft})" | Match / Puść |

### G. Sztab (5 wzorców)

| type | kind | default | escalate | title | body | decision |
| ---- | ---- | ------- | -------- | ----- | ---- | -------- |
| `staffOfferResponse` | (5 kinds jak contractOfferResponse) | jak kontrakty | — | jak kontrakty z `subjectKind: staff` | — | jak kontrakty |
| `staffSigned` | — | normal | — | „Sztab: {name} ({role})" | „Podpisany na {years} lat, {salary}/rok." | — |
| `staffGrowthDigest` | — | normal | — | „Rozwój sztabu" | „{growthCount} zmian atrybutów w sztabie." | — |
| `retirementStaff` | — | normal | HC/Scout → urgent | „Emerytura sztabu: {name}" | „{name} ({role}, {age}) kończy karierę. Slot wolny." | — |
| `staffSlotEmpty` | — | normal | przed tyg. 1 → urgent | „Pusty slot: {role}" | „Brak {role} — kara do momentu obsadzenia." | — |

### H. Wymiany (8 wzorców)

| type | kind | default | title | body | decision |
| ---- | ---- | ------- | ----- | ---- | -------- |
| `tradeOffer` | — | **urgent** | „Oferta: {partnerTeam}" | „Oferują: {inSummary}. Za: {outSummary}." | Accept / Counter / Reject |
| `tradeCounter` | — | **urgent** | „Kontroferta: {partnerTeam}" | „Nowa propozycja (runda {round}): {details}." | Accept / Counter / Reject |
| `tradeOutcome` | `accepted` | **urgent** | „Wymiana wykonana!" | „{outSummary} → {partnerTeam}. Otrzymano: {inSummary}." | — |
| `tradeOutcome` | `rejected` | normal | „Wymiana odrzucona" | „{partnerTeam} odrzucił ofertę." | — |
| `tradeOutcome` | `hardRejected` | normal | „Blokada: {partnerTeam}" | „Twarde odrzucenie — blokada 30 dni." | — |
| `ntcRefusal` | — | **urgent** | „Odmowa NTC: {playerName}" | „{playerName} nie wyraził zgody na transfer do {destTeam}. Blokada 30 dni." | — |
| `tradeLeagueDigest` | — | silenced | „Wymiany w lidze (tyg. {week})" | „{count} wymian AI↔AI w tym tygodniu." | — |
| `tradeWindowEvent` | `open` | normal | „Okno wymian otwarte" | „Od dziś można handlować zawodnikami i pickami." | — |
| `tradeWindowEvent` | `deadlineReminder` | normal | tyg. 21–23 → urgent (konfigurowalne) | „Trade deadline: {daysLeft} dni" | „Ostatnia szansa na wymianę w tym sezonie." | — |

### I. Draft i skauting (11 wzorców)

| type | kind | default | title | body | decision |
| ---- | ---- | ------- | ----- | ---- | -------- |
| `lottery` | — | **urgent** | „Loteria draftowa" | „Twój pick 1. rundy: #{pickNumber}." | — |
| `scoutReportMonthly` | — | normal | „Raport scouta ({month})" | „Obserwowanych: {count}. Nowe tiery: {newTiers}." | — |
| `scoutReportEvent` | — | **urgent** | „Scout Report — assign Combine" | „Przypisz prospektów na Combine (limit: {limit})." | Otwórz watchlist |
| `combineResults` | — | normal | „Wyniki Combine" | „{assignedCount} prospektów — odkryto role i cechy." | — |
| `mockDraft` | `initial` | normal | „Mock wstępny (klasa {year})" | „Nowa klasa — {count} prospektów." | — |
| `mockDraft` | `final` | normal | „Mock finalny (klasa {year})" | „Finalny ranking — board gotowy na draft." | — |
| `draftPickOwn` | — | **urgent** | „Twój pick: #{pickNumber}" | „Wybierz prospekta z dostępnej puli." | Otwórz draft |
| `draftPickLeague` | — | silenced | „Pick #{pickNumber}: {teamName}" | „{teamName} wybiera {prospectName} ({position})." | — |
| `draftClassGenerated` | — | normal | „Nowa klasa draftowa ({year})" | „{count} prospektów — skauting od tyg. 46." | — |
| `undraftedPool` | — | normal | „Niedraftowani ({count})" | „{count} prospektów trafia do puli FA." | — |
| `draftedRightsReminder` | — | normal | „Niepodpisany draftowany: {playerName}" | „Prawa do {playerName} — roster {rosterCount}/30." | — |

### J. Finanse (3 wzorce)

| type | default | escalate | title | body | decision |
| ---- | ------- | -------- | ----- | ---- | -------- |
| `capUpdateTv` | **urgent** | — | „Nowy salary cap!" | „Zmiana z {old} na {new} ({pct}%). Progi apronów zaktualizowane." | — |
| `apronWarning` | normal | >2nd apron → urgent | „Przekroczenie aprogu" | „Payroll: {payroll}. Poziom: {apronLevel}. Ograniczenia: {restrictions}." | — |
| `staffCapViolation` | **urgent** | — | „Błąd staff cap!" | „Staff payroll {staffPayroll} > limit {staffCap}. Wymagana korekta." | — |

### K. Sezon i nagrody (6 wzorców)

| type | kind | default | escalate | title | body |
| ---- | ---- | ------- | -------- | ----- | ---- |
| `award` | `mvp` / `roty` / `dpoy` / `topScorer` / `topAssists` / `bestGk` / `tots` / `coach` / `champion` | normal | własny → urgent | „Nagroda: {awardName}" | „{winnerName} ({teamName}) — {awardName} sezonu {year}." |
| `playoffSeeding` | — | normal | — | „Drabinka playoff" | „Twoja drużyna: seed #{seed}, przeciwnik: {opponent}." |
| `playInResult` | — | normal | — | „Play-in: {result}" | „{teamA} {goalsA}:{goalsB} {teamB}." |
| `playoffMissed` | — | **urgent** | — | „Brak awansu do playoff" | „Oczekiwania niespełnione. Atmosfera −{penalty}." |
| `seasonSummary` | — | normal | — | „Podsumowanie sezonu {year}" | „Pozycja: #{place}. W-D-L: {w}-{d}-{l}. Top scorer: {scorer} ({goals})." |
| `teamStatusChange` | — | normal | — | „Zmiana statusu: {newStatus}" | „Twoja drużyna: {oldStatus} → {newStatus}." |

### L. System (2 wzorce) + `ovrDigest`

| type | default | domain | groupKey | title | body |
| ---- | ------- | ------ | -------- | ----- | ---- |
| `calendarReminder` | normal | system | — | „Nadchodzący event: {eventName}" | „{eventName} w {day}, tyg. {week}." |
| `system` | wg kontekstu | system | — | „Komunikat systemowy" | „{message}" |
| `ovrDigest` | silenced | playerEvent | `ovr:own:{week}` | „Rozwój OVR" | „{count} zawodników poprawiło OVR w tym tygodniu." |

---

## 9. Agregacja i digesty

Przy ≥ 3 wiadomościach tego samego `groupKey` w jednym dniu: zwijane w **digest** (jedna wiadomość zbiorcza).

| Digest | `groupKey` | Częstotliwość | Przykład |
| ------ | ---------- | ------------- | -------- |
| Wymiany w lidze | `trade:league:{week}` | tygodniowo | „5 wymian AI↔AI w tym tygodniu" |
| Emerytury ligowe | `retire:league:{week44}` | raz (tyg. 44) | „12 zawodników przeszło na emeryturę" |
| Picki innych drużyn | `draft:round:{n}` | 3× (per runda) | „Runda 1 zakończona — 30 picków" |
| Rozwój OVR (własny) | `ovr:own:{week}` | tygodniowo | „3 zawodników +1 OVR" |
| Staff growth | `staff:growth:{year}` | raz (tyg. 44) | „4 zmiany atrybutów w sztabie" |

Digesty **nie zastępują** wiadomości `urgent` — te zawsze idą osobno. Digest dotyczy wyłącznie `normal` i `silenced`.

### Deduplikacja

`dedupKey` zapobiega powtórzeniu tej samej informacji:
- `injury:{playerId}:{injuryId}` — ta sama kontuzja nie generuje drugiej wiadomości
- `contractOffer:{negotiationId}:{round}` — ta sama runda negocjacji nie duplikuje się
- `tradeOffer:{tradeOfferId}` — jedna oferta = jedna wiadomość

---

## 10. Budżet wolumenu

| Metryka | Cel |
| ------- | --: |
| Wiadomości w inboksie na sezon | **250–350** |
| Udział `urgent` | **8–15%** (~25–45) |
| Max `urgent` na dzień | **bez limitu** (bo dostarczane raz na start dnia) |
| Max nieprzeczytanych w inboksie | **50** (starsze auto-read) |
| Digesty na sezon | ~30–40 |

Ponieważ wiadomości przychodzą **raz dziennie** (nie w trakcie dnia), nie ma problemu z wielokrotnym pauzowaniem. Gracz dostaje pakiet, przetwarza wszystkie `urgent` za jednym razem, i idzie dalej.

---

## 11. Retencja i archiwum

| Zasada | Wartość |
| ------ | ------- |
| W inboksie: bieżący + poprzedni sezon | 2 sezony |
| Archiwum | bez limitu, dostępne w UI jako oddzielna zakładka |
| Wiadomości z `payload` wskazującym na nieistniejący byt (emerytowany zawodnik, anulowana wymiana) | degradacja do wpisu historycznego, CTA usunięte |
| Wiadomości `silenced` | trafiają **wyłącznie** do archiwum, poza inboxem |

---

## 12. Decyzje i terminy

Każda wiadomość decyzyjna ma:

| Pole | Opis |
| ---- | ---- |
| `decision.options` | lista opcji (Accept, Decline, Counter, Ignoruj itp.) |
| `decision.defaultOnExpiry` | opcja wywoływana automatycznie po upływie terminu |
| `expiresAt` | konkretny moment; po nim symulacja wymusza `defaultOnExpiry` |

Źródła terminów:

| Typ decyzji | Termin | Źródło |
| ----------- | ------ | ------ |
| Eventy zespołu (team_management.md) | koniec dnia (= Ignoruj → Decline) | `team_management.md` |
| Eventy zawodnika (player_management.md) | +1–3 dni | `player_management.md` |
| Contract Accept → finalizacja | FA I: 3h / koniec dnia; FA II: 3 dni; Extension: 1 dzień | `contracts.md` §5 |
| Contract Counter → reakcja | FA I: koniec dnia; FA II: 3 dni | `contracts.md` §5 |
| Trade offer → reakcja | +7 dni lub trade deadline (co wcześniej) | `trades.md` |
| RFA match → reakcja | FA I: 3h / koniec dnia; FA II: 3 dni | `contracts.md` §5 |
| QO do złożenia | koniec okna extension | `contracts.md` §8 |

AI odpowiada na wiadomości decyzyjne **natychmiast** (tego samego dnia / tej samej godziny). Gracz ma pełny termin.

---

## 13. Domyślne priorytety — podsumowanie (szybki lookup)

| Zawsze `urgent` | Zawsze `normal` | Zawsze `silenced` | Eskalowalne |
| --------------- | --------------- | ----------------- | ----------- |
| walkover | matchPreview | suspensionEnd | injury |
| lineupNoGk | matchResult | draftPickLeague | retirementPlayer |
| rosterBelowMin | benchIncomplete | tradeLeagueDigest | suspensionStart |
| capUpdateTv | contractSigned | retirementLeagueDigest | apronWarning |
| staffCapViolation | contractExpiring | ovrDigest | award |
| lottery | contractLostToRival | | staffSlotEmpty |
| scoutReportEvent | playoffSeeding | | tradeWindowEvent.deadline |
| draftPickOwn | playInResult | | |
| promiseBroken | seasonSummary | | |
| playoffMissed | teamStatusChange | | |
| tradeOffer/Counter | scoutReportMonthly | | |
| contractOfferResponse.accept | combineResults | | |
| contractOfferResponse.counter | mockDraft | | |
| contractOfferResponse.hardReject | staffGrowthDigest | | |
| rfaQualifyingOffer | calendarReminder | | |
| rfaOfferSheet | leaderSupport | | |
| ntcRefusal | declineToExtend | | |
| | atmosphereShift | | |
| | all playerEvent (auto) | | |

---

## 14. UX — szkic

```
┌──────────────────┬────────────────────────────────────┐
│  KALENDARZ       │  INBOX                             │
│  Tyg. 12, Pon    │  [🔴] Kontuzja: Kowalski (urgent)  │
│                  │  [🔴] Oferta: FC Barcelona (urgent) │
│  Event: Mecz     │  [ ] Raport scouta (normal)        │
│                  │  [ ] Wymiany w lidze (digest)       │
│  [Symuluj ▶]    │                                    │
│                  │  ─── Przeczytane ───               │
│                  │  [✓] Wynik: Team A 2:1 Team B      │
│                  │  [✓] Podpis: Nowak                 │
├──────────────────┴────────────────────────────────────┤
│  [⚙ Ustawienia powiadomień]  [📁 Archiwum]           │
└───────────────────────────────────────────────────────┘
```

Klik na wiadomość → szczegóły + CTA. Wiadomości `urgent` mają czerwoną flagę i blokują przycisk „Symuluj" do momentu acknowledge.

### Widok szczegółowy wiadomości decyzyjnej

```
┌─────────────────────────────────────────┐
│ 🔴 Prośba o transfer: Kowalski          │
│                                         │
│ Kowalski chce odejść. Atmosfera drużyny │
│ poniżej 40 od 5 tygodni.               │
│                                         │
│ Termin: do końca dnia                   │
│                                         │
│ [Accept]  [Decline]                     │
│                                         │
│ [→ Profil zawodnika]  [→ Finanse]       │
└─────────────────────────────────────────┘
```

---

## 15. Parametry balansu

Wszystkie stałe do `/balance/messages_balance.dart`.

| Parametr | Wartość | Sekcja |
| -------- | ------: | ------ |
| `INBOX_RETENTION_SEASONS` | 2 | §11 |
| `DIGEST_MIN_ITEMS` | 3 | §9 |
| `MAX_UNREAD_INBOX` | 50 | §10 |
| `SCOUT_REPORT_DAY` | 1 (pon) | §8.I |
| `TRADE_OFFER_EXPIRY_DAYS` | 7 | §12 |
| `TEAM_EVENT_EXPIRY` | koniec dnia | §12 |
| `PLAYER_EVENT_EXPIRY_DAYS` | 1–3 (per kind) | §12 |
| `FA_ACCEPT_FINALIZE_HOURS` | 3 | §12 |
| `FA_ACCEPT_FINALIZE_DAYS` | 3 | §12 |
| `EXT_ACCEPT_FINALIZE_DAYS` | 1 | §12 |
| `HARD_REJECT_BLOCK_DAYS` | 30 | §8.F |

---

## 16. Kryteria akceptacji

| Metryka | Przedział |
| ------- | --------- |
| Wiadomości na sezon | 250–350 |
| Udział `urgent` | 8–15% |
| Każdy event silnika ma przypisany wzorzec lub jawnie `silenced` | 100% |
| Zero literałów tekstowych poza `.arb` | 100% |
| Każda wiadomość decyzyjna ma `defaultOnExpiry` | 100% |
| Żaden dzień symulacji z wiadomością decyzyjną przeterminowaną bez rozstrzygnięcia | 0 |
| Digesty per sezon | 30–40 |
| Trafność eskalacji (gracz nie ignoruje >80% urgent) — testowalny po MVP | ≥ 60% |
