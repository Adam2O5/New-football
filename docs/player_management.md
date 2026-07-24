# Zarządzanie zawodnikiem — atrybuty, rozwój, potencjał, kontuzje

Dokument projektowy: reguły działania zawodników w karierze.  
Powiązane: `staff_rules.md` (skauting, development sztabu), `matchday_model.md` (wkład w meczu), `squad_management.md` (zgranie / atmosfera), `tactics.md` (role), `trade_rules.md` (`pointValue`).

---

## 1. Profil zawodnika (skrót)

| Element | Skala / typ | Widoczność |
| ------- | ----------- | ---------- |
| Pozycja (`Position`) | enum | jawna |
| Optymalna rola (`AssignedRole`) | zależna od pozycji | jawna |
| Overall | 50–99 | jawny |
| Atrybuty FUT (6) | 50–99 | jawne |
| Stamina | 0–100 | jawna |
| Form | 1–10 | jawna |
| Osobowość (`PlayerPersonality`) | enum | jawna |
| Potencjał (gwiazdki) | 0,5–5,0 (krok 0,5) | ukryty u prospectów do scoutingu |
| `injuryProne` | 1–10 | ukryty (prospect: po scoutingu) |
| `determination` | 1–10 | ukryty (prospect: po scoutingu) |
| `overallProgress` | 0–99% | ukryty — ile przyrostu zostało do soft-capu |
| `growthRate` | 0–2 (baza 1) | ukryty — tempo rozwoju |
| `pointValue` | −1000…1000 | jawny (w UI wymian / scouting trade) |

---

## 2. Atrybuty jawne

Inspiracja: karty FUT. Sześć statystyk buduje **overall**.

| Atrybut | Zakres | Znaczenie (skrót) |
| ------- | ------ | ----------------- |
| Pace | 50–99 | szybkość, przyspieszenie |
| Shooting | 50–99 | wykończenie, strzał |
| Passing | 50–99 | podania, wizja |
| Dribbling | 50–99 | prowadzenie piłki, pierwszy kontakt |
| Defending | 50–99 | odbiór, krycie, pozycjonowanie |
| Physicality | 50–99 | siła, agresja, wytrzymałość walki |

### Overall

- Overall ∈ **[50, 99]** (zaokrąglenie do liczby całkowitej w UI).
- Liczony jako **średnia ważona** sześciu atrybutów według pozycji (wagi jak w FUT / silniku — wyższe wagi kluczowych cech pozycji, np. ST: Shooting/Pace/Physicality).
- Rola (`AssignedRole`) **nie wchodzi** do overall, ale modyfikuje wkład w meczu (patrz `matchday_model.md` + opisy ról w `enums.dart`).

### Stamina (0–100)

- Bieżące „siły do gry”: spada przy minutach, regeneruje się między meczami / w rest days.
- Niska stamina obniża wkład meczowy i **zwiększa ryzyko kontuzji** (sekcja 6).

### Form (1–10)

- Krótki streak formy: wpływa na skuteczność w meczu.
- Aktualizacja po meczach (wynik indywidualny + wynik drużyny); clamp 1–10.

### Pozycja i optymalna rola

- Każdy zawodnik ma jedną pozycję bazową (`Position`).
- Ma też przypisaną / preferowaną rolę (`AssignedRole` zgodną z pozycją), np. CB → `ballPlayingDefender`.
- Gra poza optymalną rolą / pozycją: kara do wkładu meczowego (bez natychmiastowej zmiany overall).

### Osobowość

Patrz sekcja 7.

### Potencjał (gwiazdki)

Patrz sekcja 4–5. Skala **półgwiazdkowa** (0,5 … 5,0).

---

## 3. Atrybuty niejawne

Niedostępne w standardowym UI karty zawodnika. Prospect: odsłaniane przez skauting (`staff_rules.md`).

### `injuryProne` (1–10)

- Podatność na kontuzje (częstotliwość / waga rolli).
- **1** = bardzo odporny, **10** = bardzo podatny.
- Mnoży bazowe P(kontuzja) w meczu / treningu.

### `determination` (1–10)

- Szansa, że zawodnik **wykorzysta** (lub przekroczy / nie dojdzie do) potencjału gwiazdkowego.
- Bazowa tabela: sekcja 5.

### `pointValue` (−1000 … 1000)

- Wskaźnik wartości w wymianach; **pochodna atrybutów jawnych** (overall + jakość 6 FUT + wiek / lata kontraktu mogą być włączone jako korekty, ale rdzeń to jawne staty).
- Formuła startowa (projekt):

```text
raw = (overall − 70) × 35
    + (avgFUT − 70) × 15
    + ageAdj          // młodzi z wysokim potencjałem: lekki +; starzy: −
pointValue = clamp(round(raw), −1000, 1000)
```

- `avgFUT` = średnia Pace…Physicality.
- Ujemne wartości: fringe / depth; wysokie dodatnie: gwiazdy / kluczowi starterzy.

### `overallProgress` (0–99%)

- Niejawny wskaźnik: **ile pozostało** przyrostu atrybutów / overall do soft-capu ścieżki (potencjał ★ × determination).
- **0%** = zawodnik praktycznie wyczerpał wzrost (plateau / peak achieved).
- **99%** = prawie cały wzrost jeszcze przed nim (młody / niski overall względem sufitu).
- Spada w miarę treningów i meczów; nie jest widoczny w standardowym UI karty.
- W fazie decline (≥ 33) `overallProgress` nie „odnawia” wzrostu — decline idzie osobną ścieżką spadku.

### `growthRate` (0–2, baza 1.0)

- Niejawny mnożnik tempa postępu w treningach i meczach.
- Baza: **1.0**. Clamp końcowy: **0.0–2.0**.

```text
growthRate = clamp(1.0 + ΣΔ, 0.0, 2.0)
```

| Czynnik | Kierunek (orientacja) |
| ------- | --------------------- |
| Forma wysoka (8–10) | +0.05…0.15 |
| Forma niska (1–3) | −0.10…0.20 |
| Head Coach / Youth Coach Development ★ | +0.05…0.25 |
| Atmosfera drużyny | ±0.05…0.15 |
| Gra na optymalnej **pozycji** | +0.05…0.10 |
| Gra na optymalnej **roli** | +0.05…0.10 |
| Regularne minuty | +0.05…0.15 |
| Brak minut | −0.10…0.25 |
| `determination` wysokie | +0.05…0.15 |
| Faza wieku ≤ 26 | pełne zastosowanie growthRate |
| Faza 27–32 | growthRate × ~0.35 (plateau) |
| Faza ≥ 33 | growthRate nie podnosi overall (decline) |

Specjalne umiejętności zawodników: **poza zakresem** — `Może_kiedyś_do_dodania.md`.

Przyrost tygodniowy / po meczu (szkic):

```text
Δprogress ≈ f(minutes, training) × growthRate
// zużywa overallProgress; mapuje na +FUT / +overall w kierunku soft-capu
```

---

## 4. Potencjał (gwiazdki) ↔ zakres overall

Gwiazdki opisują **przybliżony sufit overall**, nie bieżącą ocenę.

| Potencjał (★) | Przybliżony sufit overall |
| ------------- | ------------------------- |
| 0,5 | 50–55 |
| 1,0 | 56–60 |
| 1,5 | 61–65 |
| 2,0 | 66–70 |
| 2,5 | 71–75 |
| 3,0 | 76–80 |
| 3,5 | 81–85 |
| 4,0 | 86–88 |
| 4,5 | 89–91 |
| 5,0 | 92–99 |

> Przykład z briefu (4,5★ ≈ 86–91) jest zbliżony; tabela powyżej uniką nakładania się z 4,0★ — przy tuningu można przesunąć o ±1 overall.

### Widoczność u prospectów

- Przed scoutowaniem: potencjał **niewidoczny** (UI: `???` / brak gwiazdek).
- Po wystarczającym scoutingu: potencjał widoczny (z ewentualnym szumem tieru — `staff_rules.md`).
- `determination` i `injuryProne` prospectu: odkrywane osobno przez skauting (wyższe tiery).

### Spadek potencjału

- **Major injury** może obniżyć potencjał o **0,5★** (rzadziej o 1,0★ przy bardzo ciężkich / powtarzających się major).
- Clamp dolny: 0,5★.
- Minor injuries **nie** obniżają potencjału.

---

## 5. Rozwój (development)

### Fazy wiekowe

| Wiek | Faza | Przyrost atrybutów / overall |
| ---- | ---- | ---------------------------- |
| ≤ 26 | Development | pełny / normalny wzrost w kierunku sufitu |
| 27–32 | Peak / plateau | przyrost **znacznie mniejszy**; utrzymanie formy ważniejsze |
| ≥ 33 | Decline | statystyki **zaczynają spadać** (tempo zależne od pozycji; Pace/Physicality szybciej) |

Uwaga: „do 26. roku” = wzrost do końca sezonu, w którym zawodnik kończy 26 lat (implementacja: `age <= 26`).

### Cel rozwoju

- Soft target = losowany wynik ścieżki względem **gwiazdek potencjału** i `determination` (poniżej).
- Tempo dojścia: `growthRate` × minuty / treningi; zużywa `overallProgress` (sekcja 3).
- Head Coach / Youth Coach Development ★ (`staff_rules.md`) wpływają przez `growthRate`, nie przez tabelę determination.

### Determination → szansa względem potencjału

Wynik ścieżki kariery (ustalany raz / rzadko aktualizowany, nie co mecz):

| Wynik | Znaczenie |
| ----- | --------- |
| **Exceed** | overall-sufit lepszy niż gwiazdki (np. +0,5★ względem tabeli) |
| **Hit** | osiągnięcie potencjału (środek / górny zakres gwiazdek) |
| **Under** | nieosiągnięcie: sufit o **0,5★ lub 1,0★** niższy |

**Baza (`determination = 5`):** 10% Exceed · 50% Hit · 40% Under.

| Determination | Exceed | Hit | Under |
| ------------- | ------ | --- | ----- |
| 1 | 1% | 20% | 79% |
| 2 | 2% | 28% | 70% |
| 3 | 4% | 36% | 60% |
| 4 | 7% | 43% | 50% |
| 5 | 10% | 50% | 40% |
| 6 | 14% | 54% | 32% |
| 7 | 18% | 57% | 25% |
| 8 | 23% | 57% | 20% |
| 9 | 28% | 57% | 15% |
| 10 | 35% | 55% | 10% |

Przy **Under**: 60% szans na −0,5★, 40% na −1,0★ (względem nominalnego potencjału).  
Przy **Exceed**: typowo +0,5★ do sufitu (rzadko +1,0★ przy determination ≥ 9).

---

## 5b. Emerytura zawodnika

Szczegóły eventowe: `offseason.md` §3 (środa tyg. 44).

- Roll P(retire) dla wieku **33+** z tabelą bazową + modyfikatory (spadek OVR, minuty, kontuzje, osobowość, atmosfera, brak playoff).
- Cel balansu: &lt;33 prawie nigdy; mediana odejścia **35–36**; ~**1%** nadal gra w wieku **38**.
- Po emeryturze BR: czas na następcę do tyg. **1** — bez hard-min GK w rosterze.

---

## 6. Kontuzje

### Typy

| Typ | Czas trwania | Wpływ |
| --- | ------------ | ----- |
| **Minor** | 1 dzień – 4 tygodnie | niedostępność; bez spadku potencjału |
| **Major** | 5 tygodni – 1 rok | długa absencja; możliwy spadek potencjału (−0,5★, rzadko −1,0★) |

Losowanie długości: równomierne / lekko skośne w przedziale typu (do tuningu w kodzie).

### Czynniki ryzyka

1. **`injuryProne` (1–10)** — główny ukryty mnożnik częstotliwości.
2. **Stamina** — granie przy niskiej staminie podnosi P(injury):
   - stamina ≥ 60: brak kary;
   - 40–59: lekki mnożnik (np. ×1,25);
   - &lt; 40: silny mnożnik (np. ×1,75);
   - **wielokrotne** mecze poniżej progu w krótkim oknie (np. 3+ w 14 dniach): dodatkowy stack ryzyka.
3. **Osobowość `professional`** — zmniejsza szansę kontuzji (cecha osobowości).
4. Kontekst meczu: intensywność, kartki, zmęczenie sezonowe (`matchday_model.md`).

### Przebieg

1. Roll kontuzji w meczu / po meczu (lub rzadko na treningu).
2. Roll typu: minor vs major (wyższe `injuryProne` → większy udział major).
3. Losowanie dni absencji w zakresie typu.
4. Przy major: roll spadku potencjału.
5. Regeneracja: zawodnik niedostępny do `injuryDaysRemaining = 0`; stamina/form po powrocie startują obniżone (do ustalenia w balansie).

Kontuzje **odnawiające się** (chronic): poza MVP — `Może_kiedyś_do_dodania.md`.

---

## 7. Zachowanie i osobowość

Osobowość wpływa na:

- **zgranie / chemistry** i atmosferę szatni (`squad_management.md`),
- **kompatybilność z trenerami** (profil sztabu / `ManagerProfile`),
- decyzje kontraktowe / trade demand (cechy poniżej).

| Osobowość | Cecha (efekt) |
| --------- | ------------- |
| `professional` | mniejsza szansa kontuzji |
| `leader` | boost chemistry i morale szatni |
| `temperamental` | wyższy peak formy, więcej kartek i wahań formy |
| `ambitious` | szybszy rozwój przy walce o tytuł / regularnych minutach |
| `loyal` | rzadziej żąda trade / rzadziej odrzuca przedłużenie |
| `balanced` | brak skrajności; stabilny temperament |

### Kompatybilność z trenerem (projekt)

- Zgodność osobowości z filozofią sztabu / profilem menedżera → bonus chemistry (`squad_management.md`).
- Konflikt (np. `temperamental` vs bardzo restrykcyjny staff) → kara atmosfery / chemii.
- Szczegóły wag: przy implementacji chemistry w `squad_management.md`.

---

## 8. Scouting — co widać

| Informacja | Przed scoutem (prospect) | Po scoutingu |
| ---------- | ------------------------ | ------------ |
| Pozycja, wiek, narodowość | tak | tak |
| Atrybuty FUT / overall | zaszumione / ukryte (tiery) | coraz dokładniej |
| Potencjał ★ | **niewidoczny** | widoczny |
| `determination` | ukryty | odkrywalny |
| `injuryProne` | ukryty | odkrywalny |
| Form, stamina (gracz ligowy) | tak (bieżące) | tak |

Dokładne tiery raportu: `staff_rules.md`.

---

## 9. Podsumowanie zależności

```text
FUT attrs (50–99) ──► overall (50–99)
                 └──► pointValue (−1000…1000)

potential ★ + determination ──► soft-cap ścieżki
overallProgress (0–99%)      ──► ile wzrostu zostało
growthRate (0–2)             ──► tempo treningów/meczów
age (≤26 / 27–32 / ≥33)      ──► tempo wzrostu / spadku
major injury                 ──► możliwy spadek ★
age 33+ + modyfikatory       ──► P(emerytura)

injuryProne × stamina × personality ──► P(kontuzja)
personality × staff                ──► chemistry / zachowanie
```

---

## 10. Status względem kodu

Część pól w modelu (`PlayerAttributes`, `PlayerCareerStats`) nadal używa starszych nazw / skal (np. form 0–100, `fitness` zamiast `stamina`, `technique` zamiast dribbling, potencjał liczbowy zamiast ★). Ten dokument jest **źródłem prawdy projektowej** — migracja modelu i silnika powinna do niego dążyć; stałe liczbowe w kodzie / `BalanceConfig`.
