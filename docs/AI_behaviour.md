# Wstępny plan zachowania AI (możliwe zmiany)

# Zachowanie AI menedżerów

Dokument zbiera reguły zachowania drużyn AI (draft, wymiany, salary cap, taktyka).  
Poziom trudności wybierany przy starcie kariery: **Normal** (domyślny) lub **Hard**.

---

## Profile menedżera

Każda drużyna AI ma profil wynikający z `aggressionLevel` i `riskTolerance`:

| Profil       | Próg agresji     | Charakter                                          |
| ------------ | ---------------- | -------------------------------------------------- |
| `cautious`   | aggression < 0,35 | unika ryzyka, broni capu, ostrożne oferty          |
| `balanced`   | 0,35–0,7         | standardowe decyzje                                |
| `aggressive` | aggression > 0,7 | rebuild / win-now, ryzykowniejsze wymiany i draft |

Profil **ewoluuje** po sezonie względem oczekiwań (`expectedWins ≈ conferenceSize × 0,5`):

- słaby sezon (wins < expected − 5) → wzrost agresji i ryzyka
- dobry sezon (wins > expected + 5) → spadek agresji i ryzyka

Siła i tempo tej adaptacji zależą od poziomu trudności (poniżej).

---

## Poziomy trudności — przegląd

| Obszar              | Normal                                      | Hard                                              |
| ------------------- | ------------------------------------------- | ------------------------------------------------- |
| Cel                 | nauka rozgrywki, przewidywalne AI           | wymagająca rywalizacja, trudna współpraca         |
| Styl decyzji        | zachowawczy, bezpieczne wybory              | adaptacyjny, wykorzystuje słabości gracza         |
| Oferty gracza       | częściej akceptuje „fair” pakiety           | rzadko akceptuje; wymaga wyraźnej przewagi wartości |
| Błędy / szum        | widoczny szum w ocenie wartości             | mały szum; decyzje blisko optymalnych             |
| Finanse             | unika 2nd apron; rzadko luxury tax          | świadomie używa apronów przy windowie tytułowym   |
| Kontr-taktyka       | wolna / ograniczona                         | szybka i trwała                                   |

---

## Normal — szczegóły

Tryb do nauki: AI gra solidnie, ale nie „czyta” gracza agresywnie i nie blokuje każdej sensownej współpracy.

### Draft

- Wybór: **potrzeby pozycji** (mniej niż 2 zawodników na pozycję) → potem najlepsza dostępna wiedza skautingowa / `scoutGrade`.
- Rebuild (`aggression > 0,6`): lekki bias w stronę `potential`, ale nadal respektuje ocenę scouta.
- Board UI sortuje mock finalny; AI używa własnej wyceny (`draft_rules.md`).
- Nie „kradnie” celowo prospektów z watchlisty gracza, jeśli ma równorzędną alternatywę pasującą do potrzeb.
- Reaguje pick po picku, bez głębokiego przewidywania boardu gracza.

### Wymiany

- Respektuje te same reguły cap / apron / Stepien / roster **20–30** co gracz (bez min. GK).
- Akceptuje oferty w okolicy **fair value** (± ok. 10–15% wartości pakietu).
- Agresywność handlu rośnie dopiero przy wyraźnym niedoszacowaniu oczekiwań — wolniej niż na Hard.
- Przy NTC / limited NTC częściej odpuszcza, zamiast forsować zgodę zawodnika.

### Salary cap, FA i kontrakty

Kolejność preferencji (jak w `salary_cap_rules.md`):

1. Cap space  
2. Rookie scale  
3. Bird rights  
4. MLE (1× na cykl FA)

- Negocjacje: rytm **10h/dzień** — `contract_signing.md` (extensions + FA + staff); RFA: QO + match offer sheet — `salary_cap_rules.md`.
- Unika wejścia powyżej **2nd apron**.
- Przedłużenia Bird: oferuje rozsądne, nie maksymalne kontrakty.
- Nie przechowuje długich, ciężkich kontraktów „dla zablokowania rynku”.
- Pilnuje rosteru 20–30 (unika walkowerów); po emeryturze BR celuje w podpis do tyg. 1.

### Sztab

- Utrzymuje 6 slotów (`staff_rules.md`); na Normal akceptuje 2–3 słabsze role by zmieścić się w staff cap.
- Skauting: assign w limicie Coverage; Combine focus na potrzeby pozycji.

### Taktyka i skład

- Lineup: najlepsi dostępni na pozycje formacji; **zawsze** stara się wystawić `Position.gk` w bramce (kara 0–5).
- Profil `cautious` / `aggressive` wpływa na pressing i linię obrony, ale bez kontr-taktyki uczącej się stylu gracza.
- Kontuzje: proste zastępstwa pozycji; bez optymalizacji obciążenia całego sezonu.

### Współpraca z graczem

- Łatwiej dogadać się o picki późnych rund i role depth.
- AI nie eskaluje wojny ofert o tego samego FA tylko po to, by zablokować gracza.
- Po odrzuceniu oferty gracza bywa skłonna wrócić z kontrpropozycją bliższą fair value.

---

## Hard — szczegóły

Tryb wymagający: AI jest **adaptacyjna** i **trudna do współpracy** — traktuje gracza jak konkurenta, nie partnera treningowego.

### Draft

- Potrzeby pozycji + wiedza scouta; przy rebuildie silny priorytet `potential`.
- Uwzględnia depth chart — nie dubluje pozycji bez potrzeby.
- Reaguje na board gracza: jeśli gracz konsekwentnie celuje w typ prospekta, AI częściej zabiera podobne profile wcześniej (gdy to pasuje do jej potrzeb).
- Mniejszy szum oceny — lepiej wykorzystuje Evaluation / Coverage własnego scouta.

### Wymiany

- Te same reguły formalne (20–30, cap, Stepien), ale **twardsza wycena** aktywów gracza (picki 1. rundy, młodzi z potencjałem).
- Akceptacja dopiero przy wyraźnej przewadze wartości dla AI (ok. +15–25% albo krytyczna potrzeba pozycji).
- Szybka eskalacja agresji handlowej przy słabym sezonie (adaptacja po sezonie silniejsza: większe delty aggression / risk).
- Częściej inicjuje oferty „win-now” lub „dump salary” zgodnie z profilem.
- Może odmawiać nawet fair trade, jeśli wzmacnia bezpośredniego rywala konferencyjnego (anti-rival bias).

### Salary cap, FA i kontrakty

- Świadomie operuje w **1st / 2nd apron**, gdy window tytułowy jest realny.
- Bird / MLE używa optymalnie; rzadziej zostawia „martwy” cap space.
- W rytmie 10h: przebija kluczowe cele FA / HC (`contract_signing.md`).
- Może przepłacać kluczowych FA, by wypchnąć gracza z rynku (w ramach cap / apron).
- Unika Stepiena i ochrony picków lepiej niż Normal — mniej „dziur” w przyszłości klubu.

### Sztab

- Priorytet: silny Head Coach + Scout + Development (Youth); CFO może być słabszy.
- Na Hard AI lepiej alokuje Coverage i fokus Combine.

### Taktyka i skład

- Po **≥ 2** meczach z drużyną gracza włącza i utrzymuje **kontr-taktykę** (pamięć formacji / pressingu).
- Szybciej adaptuje pressing, linię i tempo do stylu przeciwnika.
- Lepsze zarządzanie kontuzjami i rotacją względem formy; zawsze GK w bramce.

### Współpraca z graczem

- Mało kontrpropozycji „na zachętę”; częściej twarde no / Hard reject.
- Walka o tych samych FA i prospektów — AI nie ustępuje „dla fair play”.
- Po udanych sezonach gracza AI rywali podnosi agresję szybciej (presja ligi).

---

## Wspólne reguły (oba poziomy)

- AI **zawsze** podlega walidacji cap / apron, rosteru **20–30** i regule Stepiena (bez min. liczby GK).
- Draft: pick po picku; drużyna gracza wybiera ręcznie, reszta wg logiki AI.
- Po drafcie: payroll += rookie scale; generacja klasy N+1 — AI planuje skauting od FA.
- Siła scout reportów zależy od sztabu (`staff_rules.md`) — słaby skauting pogarsza decyzje jednakowo (informacja); na Hard AI lepiej korzysta z odkrytej wiedzy.
- Negocjacje godzinowe: te same reguły co gracz — `contract_signing.md`.
