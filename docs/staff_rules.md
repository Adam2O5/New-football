# Sztab klubu

Dokument projektowy: role, atrybuty ★, salary cap sztabu, rozwój, emerytury, skauting.

Powiązane: `offseason.md`, `contract_signing.md`, `draft_rules.md`, `player_management.md`, `messages.md`, `national_names.md`, `AI_behaviour.md`.

Status: **projekt**. Specjalne umiejętności sztabu: **poza zakresem** — `Może_kiedyś_do_dodania.md`.

---

## 1. Role (po 1 slocie)

| Rola | EN (kod) | Główne zadanie |
| ---- | -------- | -------------- |
| **Trener główny** | `headCoach` | taktyka, motywacja, rozwój pierwszej drużyny |
| **Trener młodzieży** | `youthCoach` | rozwój młodych / wpływ na `growthRate` |
| **Scout** | `scout` | obserwacja prospectów draftu |
| **Fizjo** | `physio` | regeneracja, prewencja przeciążeń |
| **Lekarz** | `doctor` | diagnoza, czas powrotu, ryzyko powikłań |
| **CFO** | `cfo` | cap space, wsparcie negocjacji kontraktowych |

Każdy klub ma dokładnie te **6 slotów** (mogą być puste → gorsze efekty baseline).

---

## 2. Profil członka sztabu

| Pole | Skala / reguła |
| ---- | -------------- |
| Wiek | **35–60** (generacja / hire w tym zakresie) |
| Narodowość + imię / nazwisko | z puli kraju — `national_names.md` |
| Atrybuty roli | **0–5 ★**, krok **0,5** |
| Kontrakt | lata + pensja roczna |
| Pensja | wliczana do **staff salary cap** (osobny od capu zawodników) |

### Atrybuty per rola (propozycja)

| Rola | Atrybuty ★ |
| ---- | ---------- |
| Head Coach | **Tactics**, **Motivation**, **Development** |
| Youth Coach | **Development**, **Mentoring** |
| Scout | **Coverage**, **Evaluation** |
| Physio | **Rehab**, **Prevention** |
| Doctor | **Diagnosis**, **TraumaCare** |
| CFO | **CapMgmt**, **Negotiation** |

**Overall staff** (UI): średnia atrybutów roli (opcjonalnie ważona).

---

## 3. Staff salary cap (założenia ogólne)

Osobny limit od salary cap zawodników (`salary_cap_rules.md`).

### Intencja balansu

- Zespół powinien móc zatrudnić **3 silnych** + **3 wyraźnie słabszych** pracowników w ramach capu.
- Zatrudnienie **6 elite** naraz: **niemożliwe** przy generacji rynkowej; możliwe tylko przez fortunny growth ★ na długich kontraktach.
- **Waga pensji ról** (malejąco): Head Coach ≫ Youth Coach ≈ Scout ≈ Doctor > Physio > **CFO** (najtańszy).

### Placeholder liczb (do doprecyzowania)

| Parametr | Propozycja startowa |
| -------- | ------------------- |
| Staff salary cap | **12 000 000 €** / sezon |
| Pensja elite Head Coach (~4,5–5★ avg) | ~**3,5–4,5M** |
| Pensja elite CFO | ~**0,8–1,2M** |
| Pensja weak (~1–2★) | ~**0,3–0,7M** zależnie od roli |

Formuła orientacyjna:

```text
salary ≈ roleWeight × (0.4 + 0.6 × (avgStars / 5)) × marketBand
```

Przekroczenie staff cap → blokada nowego hire / przedłużenia powyżej limitu.

---

## 4. Efekty ról (skrót)

| Rola | Wpływ |
| ---- | ----- |
| Head Coach | `tactics` / morale / `growthRate` pierwszej drużyny; Coach of the Year |
| Youth Coach | `growthRate` młodych (≤ 23 / prospects w organizacji) |
| Scout | Coverage + Evaluation — sekcja 5 |
| Physio | skrócenie rekonwalescencji minor; ↓ ryzyko przeciążeniowe |
| Doctor | dokładniejsza prognoza powrotu; ↓ nawroty / major complications |
| CFO | lekki bonus w negocjacjach FA/extension; lepsze ostrzeżenia apron — `contract_signing.md` |

Puste sloty = baseline „słaby zastępca” (efekty bliskie 0–1★).

---

## 5. Scout — Coverage i Evaluation

| Atrybut | Znaczenie |
| ------- | --------- |
| **Coverage** (0–5★) | maksymalna liczba prospectów obserwowanych jednocześnie |
| **Evaluation** (0–5★) | jakość / szybkość raportów; szansa poprawnego `injuryProne` i `determination`; dokładność estymowanego slotu draftu |

### Limit obserwacji

```text
maxWatched = round(4 + Coverage × 4)   // np. 0★→4, 2.5★→14, 5★→24
```

Wartości Coverage do strojenia w kodzie.

### Kalendarz skautingu

1. **Od poniedziałku tyg. 47 (FA open):** gracz przypisuje scouta do prospectów klasy N+1 (do limitu Coverage).
2. **Ciągle przez rok:** scout przesyła raporty do inboxa; gracz ustawia **częstotliwość** raportów (np. co 3 / 7 / 14 dni).
3. **Scout Report (pon 45):** snapshot całej zdobytej wiedzy + **assign Combine** — limit ≈ **½ Coverage** (zaokrąglenie w dół, min 1 jeśli Coverage ≥ 1).
4. **Combine (śr 45):** przypisani prospecti → wyższa P(poprawny odczyt injuryProne / determination).
5. **Mock finalny (pt 45):** scout nadaje każdemu wcześniej obserwowanemu estymowany slot:  
   `Top 1` · `Top 3` · `Top 5` · `Top 10` · `R1` · `R2` · `R3` · `X`  
   (dokładność rośnie z Evaluation + czasem obserwacji + fokusem Combine).

### Tiery informacji (5 poziomów)

| Tier | Przykładowo odsłania |
| ---- | -------------------- |
| 1 | pozycja, wiek, narodowość, zgrubna projekcja |
| 2 | pomiary / combine (gdy dostępne), zakres overall |
| 3 | `scoutGrade`, główne FUT (z szumem) |
| 4 | potencjał ★ (z szumem), styl |
| 5 | `injuryProne`, `determination` (z ryzykiem błędu malejącym z Evaluation) |

Szybkość awansu tieru ∝ Evaluation.

---

## 6. Rozwój sztabu (wiek 35–45)

Moment: **po finale playoff (koniec tyg. 43), przed Awards (pon 44)**.

- **1 roll na osobę / rok.**
- Sukces: **+0,5★** do jednego lub kilku atrybutów (losowo wśród atrybutów roli; zwykle 1–2).
- Clamp atrybutu: **5,0★**.

### Szansa upgradeu (projekt)

```text
P_up = clamp(P_base + ΣΔ, 5%, 60%)
```

| Czynnik | Wpływ |
| ------- | ----- |
| P_base (wiek 35–40) | ~22% |
| P_base (wiek 41–45) | ~14% |
| Udany sezon drużyny (playoff+) | +8…12 pp |
| Coach of the Year / mocny skauting (trafione top picki) | +5…10 pp (rola) |
| Słaby sezon / kryzys atmosfery | −5…10 pp |
| Wiek bliżej 45 | −pp względem dolnej tabeli |

**Cel balansu:** łącznie ok. **+1★ sumarycznie na wszystkich atrybutach przez ~10 lat** kariery rozwojowej (nie +1★ na każdy atrybut co rok).

Wiek **46–54:** brak rollu wzrostu (stabilizacja).  
Wiek **55–60:** tylko emerytura (sekcja 7).

---

## 7. Emerytura sztabu (wiek 55–60)

Roll w tym samym momencie co growth (po finale, przed Awards), dla staffu w wieku **55+**.

| Wiek | P_base |
| ---- | -----: |
| 55 | 12% |
| 56 | 22% |
| 57 | 38% |
| 58 | 55% |
| 59 | 75% |
| 60 | **100%** (hard cap — wymuszone) |

### Modyfikatory

| Czynnik | Wpływ |
| ------- | ----- |
| Udany sezon / wysoka atmosfera | −8 pp |
| Kryzys / zwolnienie zagrożone | +10 pp |
| Długi staż w klubie + lojalny kontekst | −5 pp |
| Niskie ★ vs oczekiwania zarządu | +8 pp |

**Cel:** najczęstsze odejścia w wieku **57–58**; **60** = górna granica.

Skutek: slot pusty; hire w FA / extensions — `contract_signing.md`. Wiadomość do inboxa.

---

## 8. Zatrudnianie i AI

- Rekrutacja z puli wolnego sztabu w oknie extensions / FA (rytm 10h/dzień) — `contract_signing.md`.
- Match stylu klubu (contender / rebuild) wpływa na `want` w negocjacjach.
- AI utrzymuje minimum kompetencji; na **Hard** silniejszy skauting i Development — `AI_behaviour.md`.
- Drużyny z wyłączonym AI nie zarządzają sztabem automatycznie.

---

## 9. Powiadomienia

Typy wiadomości (flagi konfigurowalne — `messages.md`):

- kontuzje / powroty (Doctor / Physio),
- raporty scouta (częstotliwość gracza),
- Scout Report / Combine / estymowane sloty,
- wzrost ★ / emerytura sztabu,
- zatrudnienie / odejście z kontraktu.

---

## 10. Poza zakresem (na później)

- Specjalizacje / special abilities sztabu i zawodników.
- Regiony skautingu z XP.
- Rozbudowane drzewo treningów kierunkowych.

Patrz: `Może_kiedyś_do_dodania.md`.
