# Podpisywanie kontraktów (extensions, FA, sztab)

Dokument projektowy: rytm godzinowy negocjacji (wzorzec **FIFA 15** — ostatni dzień okienka) oraz **osobne** modele decyzji dla zawodników i sztabu.

Powiązane: `offseason.md`, `salary_cap_rules.md`, `staff_rules.md`, `AI_behaviour.md`, `messages.md`, `player_management.md`.

Status: **projekt**.

---

## 1. Zakres

| Okno | Kiedy | Kogo dotyczy |
| ---- | ----- | ------------ |
| **Contract extensions** | wt–niedz tyg. **46** | Własni zawodnicy (Bird) + **sztab** (wolni / wygasający) |
| **Free agency** | od pon tyg. **47** → tyg. **1** | UFA/RFA, niedraftowani, sztab FA |

Wspólne: rytm 10h/dzień i zestaw reakcji (Accept / Hard reject / Waiting / Counter).  
**Rozdzielone:** `want`, `offerScore`, progi decyzji, treść Counter — osobno dla zawodników i sztabu (§4–6).

---

## 2. Rytm dnia (10 godzin)

```text
godzina = 1 … 10
klik „symuluj godzinę” → +1h
w każdej godzinie: gracz może złożyć 1 ofertę (zawodnik LUB staff)
AI klubów składają oferty w tej samej godzinie (1 cel / klub / h)
```

- Niezużyta godzina = strata slotu oferty.
- Po 10h: koniec dnia kalendarzowego — `messages.md`.

---

## 3. Reakcje na ofertę (wspólne)

| Reakcja | Znaczenie |
| ------- | --------- |
| **Accept** | kontrakt podpisany od razu |
| **Hard reject** | koniec rozmów z tym klubem w tym oknie (v1: do końca okna) |
| **Waiting** | czeka na inne oferty (timeout: N godzin / koniec dnia) |
| **Counter** | kontrpropozycja (treść zależy od typu celu — §6) |

Po Counter: akceptacja countera, nowa oferta w **kolejnej** godzinie, lub odpuszczenie.

Walidacja twarda przed wysłaniem oferty:

- Zawodnik: salary cap / Bird / MLE / apron — `salary_cap_rules.md`; roster 20–30.
- Staff: **staff salary cap** + wolny slot roli — `staff_rules.md`.

---

## 4. Zawodnicy — model wymagań (`playerWant`)

```text
playerWant ∈ [0, 100]

playerWant =
  baseMarket(overall, age, position)
+ personalityAdj
+ playingTimeAdj
+ teamStatusAdj          // contender / mid / rebuild; atmosfera
+ rivalInterestAdj       // liczba konkurencyjnych ofert
+ tenureAdj              // extension vs FA
+ roleGuaranteeAdj       // oczekiwana rola / minuty w XI
− cfoNegotiationRelief   // lekki − przy wysokim CFO Negotiation klubu-oferenta
```

### Extension vs FA

| Czynnik | Extension | FA |
| ------- | --------- | -- |
| Overall / wiek | baza rynkowa pensji | j.w. + premium FA (~+5…12 want) |
| `loyal` | −8…12 | −3…5 |
| `ambitious` | +5 jeśli klub poza walką o tytuł | +8 do top klubów / −5 do rebuildów |
| `temperamental` | +3 bazowo (trudniej dogadać) | +5 |
| `professional` | −2…4 | −2 |
| Mało minut (&lt; 25% possible) | +10 (chce gwarancji roli) | +5 |
| Wysoka atmosfera (≥ 80) | −5 | 0 (nie dotyczy nowego klubu) |
| Bird / powyżej cap | oferta musi być legalna w exception | — |
| RFA (po rookiescale + QO) | — | offer sheet vs match — `salary_cap_rules.md`; lekki −want vs UFA |

`baseMarket` mapuje oczekiwania na skalę 0–100 względem typowej pensji pozycji/overall (mapowanie € w kodzie / `BalanceConfig`).

---

## 5. Zawodnicy — ocena oferty (`playerOfferScore`)

```text
playerOfferScore ∈ [0, 100]

playerOfferScore = 100 × (
  0.45 × salaryFit +
  0.20 × yearsFit +
  0.20 × roleFit +       // gwarancja minut / XI / AssignedRole
  0.15 × clubFit         // prestiż, atmosfera, geografia, szansa tytułu
)
```

| Składnik | Opis |
| -------- | ---- |
| `salaryFit` | oferta / oczekiwana pensja (1.0 = spot on; clamp 0…1.3 przed mapowaniem) |
| `yearsFit` | zgodność długości z preferencją wieku (młodzi 3–4 lata; 32+ 1–2) |
| `roleFit` | starter vs depth; zgodność pozycji; obietnica minut |
| `clubFit` | ranking klubu, atmosfera, odległość od „ambitious target” |

Oferta nielegalna (cap/roster) nie wychodzi z UI.

---

## 6. Zawodnicy — decision making

```text
gap = playerOfferScore − playerWant
noise = U(−3, +3)           // temperamental: U(−5, +5)
gap' = gap + noise

jeśli clubFit < 0.30 i ambitious     → Hard reject (niezależnie od pensji)
jeśli gap' ≥ +6                      → Accept
jeśli gap' ∈ [−4, +6)                → Counter ALBO Waiting jeśli ≥2 oferty w grze
jeśli gap' ∈ [−14, −4)               → Waiting (timeout) lub Counter agresywny
jeśli gap' < −14                     → Hard reject
```

### Counter (zawodnik)

- Pensja: `max(oferta, wantSalary × 1.05…1.15)`.
- Lata: preferowany zakres wieku (młodzi dłużej; 32+ krócej).
- Opcjonalnie: prośba o rolę startera / min. minut (soft clause w UI).

### Waiting (zawodnik)

- Deadline: +3h lub koniec dnia.
- Wybór: max `playerOfferScore`; przegrani dostają soft reject (można wrócić kolejnego dnia w FA).
- `loyal` w extension: krótszy Waiting, częstszy Accept przy gap' ≥ 0.

---

## 7. Staff — model wymagań (`staffWant`)

```text
staffWant ∈ [0, 100]

staffWant =
  baseMarket(avgStars, role, roleWeight)
+ styleMatchAdj          // contender / pretender / rebuild vs preferencje staffu
+ ageHorizonAdj          // 55+: woli krótsze kontrakty → ↑ want przy długich ofertach
+ vacancyUrgencyAdj      // rynek: jeśli wielu chętnych na HC → ↑ want
+ clubReputationAdj      // prestiż klubu
+ previousTenureAdj      // przedłużenie w tym samym klubie: lekki −want
− cfoNegotiationRelief   // jak u zawodników, słabszy efekt
```

**Bez** `personality` zawodnika, minut, Bird/MLE, `roleFit` minutowego.

| Czynnik | Wpływ (orientacja) |
| ------- | ------------------ |
| `avgStars` × `roleWeight` | baza (HC najwyższy weight, CFO najniższy) — `staff_rules.md` |
| Dobry style match | −8…15 want |
| Zły style match | +8…15 want |
| Wiek 55–59 | +5 want przy ofercie ≥ 3 lat; preferuje 1–2 lata |
| Przedłużenie w klubie z udanym sezonem | −5…10 |
| FA po zwolnieniu / pusty rynek na rolę | −3…6 |

---

## 8. Staff — ocena oferty (`staffOfferScore`)

```text
staffOfferScore ∈ [0, 100]

staffOfferScore = 100 × (
  0.55 × salaryFit +
  0.25 × yearsFit +
  0.15 × mandateFit +    // zakres odpowiedzialności / budżet treningów / autonomia
  0.05 × clubFit         // prestiż (słabiej niż u zawodników)
)
```

| Składnik | Opis |
| -------- | ---- |
| `salaryFit` | vs oczekiwana pensja roli × ★ |
| `yearsFit` | 35–50: 2–4 lata OK; 55+: 1–2 lata; zbyt długi kontrakt obniża mocno |
| `mandateFit` | czy oferta gwarantuje slot (HC vs „asystent w praktyce”), wpływ na taktykę / skauting |
| `clubFit` | prestiż, stabilność zarządu (lekko) |

Walidacja: staff cap + wolny slot danej roli.

---

## 9. Staff — decision making

```text
gap = staffOfferScore − staffWant
noise = U(−2, +2)            // mniejszy szum niż u zawodników
gap' = gap + noise

jeśli styleMatch < 0.25 i rola = headCoach  → Hard reject (filozofia)
jeśli gap' ≥ +5                              → Accept
jeśli gap' ∈ [−6, +5)                       → Counter (pensja/lata) ALBO Waiting jeśli ≥2 oferty
jeśli gap' ∈ [−12, −6)                      → Waiting lub Counter (głównie lata przy 55+)
jeśli gap' < −12                            → Hard reject
```

Progi są **węższe / inne** niż u zawodników: staff mniej „dramatyczny”, bardziej pensja + długość + match stylu.

### Counter (staff)

- Pensja: `max(oferta, wantSalary × 1.03…1.10)` (mniejsze przebicia niż FA gwiazd).
- Lata: przy wieku ≥ 55 wymusza skrócenie do 1–2 lat.
- HC: czasem prośba o gwarancję autonomii taktycznej (`mandateFit`).

### Waiting (staff)

- Deadline: +2h lub koniec dnia (krócej niż zawodnicy — rynek sztabu szybszy).
- Wybór: max `staffOfferScore`; przy remisie: lepszy `styleMatch`, potem dłuższy kontrakt (jeśli wiek &lt; 55).

---

## 10. Extension vs FA — różnice okien

| | Extension (tyg. 46) | FA (tyg. 47+) |
| - | ------------------- | ------------- |
| Pula zawodników | własni wygasający | cała liga FA |
| Pula sztabu | wygasający + wolni | j.w. |
| Powyżej cap (zawodnicy) | Bird / exception | MLE (1×), cap space |
| Staff | zawsze vs staff cap | j.w. |
| Hard reject zawodnika | rzadziej u `loyal` | częstsze przy lowball |
| Rytm | 10h × 6 dni | 10h × dni do tyg. 1 |

Rookie scale: **tylko draft** — poza tym silnikiem.

---

## 11. AI w godzinie

1. Wybór puli: zawodnik **albo** staff (osobne need scores).
2. Oferta liczona względem `playerWant` / `staffWant` ± agresja profilu (`AI_behaviour.md`).
3. Hard: wyższe przebicia na gwiazdy FA oraz na **Head Coach / Scout**.
4. Kolizje: cel używa własnego Waiting (§6 lub §9) i max odpowiedniego `*OfferScore`.

---

## 12. UX i wiadomości

- Accept / Counter / Hard reject / podpis AI → `messages.md`.
- Accept własny / utrata celu z Waiting → domyślnie czerwona flaga.

---

## 13. Status

Źródło prawdy negocjacji. Stałe progów gap / wag — strojenie w kodzie. RFA match: `salary_cap_rules.md`.

```text
Zawodnik:  playerWant → playerOfferScore → §6
Staff:     staffWant  → staffOfferScore  → §9
Wspólne:   10h/dzień, reakcje, inbox
```
