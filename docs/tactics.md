# Model taktyczny

Dokument projektowy: formacje, balans `def` / `mid` / `atk`, kontr-formacje, role i ustawienia taktyczne w symulacji meczu.

Powiązane: `matchday_model.md`, `player_management.md`, `squad_management.md`, `AI_behaviour.md`, `enums.dart`.

Status: **projekt** (część mnożników istniała wcześniej w `tactics_setup` / `counter_tactics` — ten dokument jest źródłem prawdy docelowej).

---

## 1. Idea przewodnia

Trzy twarde zależności kształtu składu:

| Więcej… | Efekt w meczu |
| ------- | ------------- |
| **pomocników** | ↑ posiadanie piłki, ↑ kontrola tempa, ↓ chaos przejść |
| **obrońców** | ↓ szansa straty bramki, ↑ solidność bloku, ↓ przestrzeń za plecami |
| **napastników** | ↑ szansa na gola, ↑ zagrożenie w polu karnym, ↓ naturalne posiadanie |

To jest **baza kształtu**. Na nią nakładają się:

1. atrybuty formacji `def` / `mid` / `atk` (0–100),
2. konfiguracja pasa pomocy (CDM / CM / CAM),
3. role zawodników na pozycjach,
4. ustawienia taktyczne (pressing, linia, szerokość, tempo),
5. meczup formacji (papier–kamień–nożyce).

---

## 2. Liczenie linii (D / M / A)

Każda formacja ma kształt `obrońcy–pomoc–atak` (bez bramkarza).

| Linia | Kogo liczymy |
| ----- | ------------ |
| **D** | CB + FB/WB w linii obrony (3 / 4 / 5) |
| **M** | CDM + CM + CAM + skrzydłowi ustawieni jako pomoc (LW/RW w 4-3-3 liczą się do **A**, w 4-4-2 / 4-5-1 do **M**) |
| **A** | ST + napastnicy / skrzydłowi w bloku ofensywnym |

### Formacje w grze

Wingbacki (`lwb`/`rwb`) w formacjach 5-osobowej obrony liczą się do linii **D**, zgodnie z `formation_layout.dart`.

| Formacja | Kształt (D–M–A) | Charakter |
| -------- | --------------- | --------- |
| `3-4-3` | 3–4–3 | szeroki atak, cienka obrona |
| `3-5-2` | 3–5–2 | kontrola środka, WB wysoko |
| `4-2-4` | 4–2–4 | ekstremalny atak |
| `4-3-3` | 4–3–3 | klasyczny balans szerokości |
| `4-4-2 (szerokie)` | 4–4–2 | klasyczna dwójka z przodu, skrzydłowi szeroko w pomocy |
| `4-4-2 (wąskie)` | 4–4–2 | jw., pomoc skupiona centralnie (brak szerokich skrzydłowych) |
| `4-5-1 (szerokie)` | 4–5–1 | gęsty środek z szerokimi skrzydłowymi, 1 ST |
| `4-5-1 (wąskie)` | 4–5–1 | jw., cała piątka pomocy centralnie |
| `5-2-3` | 5–2–3 | 5 obrońców (w tym WB), 3 z przodu |
| `5-3-2` | 5–3–2 | solidny blok + 2 ST |
| `5-4-1 (szerokie)` | 5–4–1 | maksymalna obrona, szerocy skrzydłowi w pomocy |
| `5-4-1 (wąskie)` | 5–4–1 | jw., pomoc skupiona centralnie |

Reguła kciuka z sekcji 1 wynika wprost z D/M/A: np. `5-4-1` ma wysokie D i M → trudniej stracić gola i utrzymać piłkę; `4-2-4` ma wysokie A → więcej sytuacji bramkowych, mniej kontroli.

---

## 3. Atrybuty formacji: `def`, `mid`, `atk` (0–100)

Każda formacja ma trzy stałe bazowe reprezentujące **balans faz gry**:

- **`def`** — odporność na straty bramek / jakość bloku,
- **`mid`** — posiadanie, przejścia, kontrola tempa,
- **`atk`** — generowanie okazji i szansa na gola.

Nie muszą sumować się do 100 — to niezależne „słupki siły” fazy. Typowy zakres baz: ~35–75, żeby ustawienia i role miały miejsce na modyfikację bez saturacji.

### Wartości bazowe (projekt)

Zgodne z `BalanceConfig.tactics.formationBaseStats` — jedyne źródło prawdy liczbowej; tabela poniżej to jej odzwierciedlenie.

| Formacja | def | mid | atk | Notatka |
| -------- | --: | --: | --: | ------- |
| `3-4-3` | 42 | 55 | 68 | ofensywna szerokość |
| `3-5-2` | 50 | 70 | 55 | król posiadania w 3 OB |
| `4-2-4` | 40 | 45 | 75 | all-in atak |
| `4-3-3` | 55 | 60 | 62 | uniwersalna |
| `4-4-2 (szerokie)` | 58 | 60 | 60 | klasyczna |
| `4-4-2 (wąskie)` | 58 | 60 | 60 | klasyczna, węższy środek |
| `4-5-1 (szerokie)` | 58 | 60 | 60 | park the midfield |
| `4-5-1 (wąskie)` | 58 | 60 | 60 | jw., bez szerokości |
| `5-2-3` | 68 | 48 | 62 | 5 OB, 3 z przodu |
| `5-3-2` | 72 | 58 | 52 | klasyczny 5-back |
| `5-4-1 (szerokie)` | 58 | 60 | 60 | ultra-def |
| `5-4-1 (wąskie)` | 58 | 60 | 60 | ultra-def, bez szerokości |

Wariacje szerokie/wąskie mają obecnie identyczne wartości bazowe (placeholder w `BalanceConfig`) — strojenie osobnych wartości to odrębne zadanie, poza zakresem tego dokumentu.

### Jak wchodzą do symulacji

```text
possessionBias   ∝  mid_team − mid_opponent  (+ liczba M)
chanceToScore    ∝  atk_team  − def_opponent (+ liczba A vs D)
chanceToConcede  ∝  atk_opponent − def_team  (+ …)
```

Dokładne wagi: silnik meczu / `BalanceConfig`. Tu ważne jest **kierunek** zależności.

---

## 4. Konfiguracja pasa pomocy (CDM / CM / CAM)

W formacjach z elastycznym środkiem menedżer **dostosowuje sloty pomocy** (ile CDM / CM / CAM w ramach limitu miejsc M danej formacji).

Przykład `4-3-3` (3 sloty M):

| Wariant | Sloty | Δ def | Δ mid | Δ atk | Efekt meczowy |
| ------- | ----- | ----: | ----: | ----: | ------------- |
| Holding | 2 CDM + 1 CM | +6 | +2 | −6 | bezpieczniej, mniej ostrza |
| Balanced | 1 CDM + 2 CM | +2 | +4 | −2 | kontrola |
| Box-to-box | 3 CM | 0 | +5 | 0 | posiadanie / przejścia |
| Creative | 1 CDM + 1 CM + 1 CAM | −2 | +3 | +4 | kreacja |
| Attack mid | 2 CM + 1 CAM | −4 | +1 | +6 | więcej okazji, ryzyko |
| Ultra-attack | 1 CM + 2 CAM | −8 | −2 | +10 | max kreacja, dziury |

Dla `4-2-3-1`, `4-1-2-1-2`, `3-5-2` itd. ta sama logika: **przesunięcie slotu w stronę CDM** wzmacnia `def` (i lekko `mid`), **w stronę CAM** wzmacnia `atk` (kosztem `def`).

Ograniczenia:

- suma slotów = liczba miejsc pomocy formacji,
- nie każda formacja pozwala na dowolny mix (np. `5-4-1` nie ma naturalnego CAM — max ofensywny slot to wysoki CM / skrzydłowy pomocy),
- UI pokazuje Δ do `def`/`mid`/`atk` na żywo.

---

## 5. Papier–kamień–nożyce (kontr-formacje)

Formacje mają **relacje przewagi**, niezależne od jakości zawodników (jakość potem mnoży efekt).

### Rodziny

| Rodzina | Formacje | Silna przeciwko | Słaba przeciwko |
| ------- | -------- | --------------- | --------------- |
| **3-back wide** | `3-4-3`, `3-5-2` | wąskie 4-4-2 / diamenty bez szerokości | szerokie 4-3-3; szybkie skrzydła |
| **4-back balanced** | `4-3-3`, `4-4-2` (szerokie/wąskie) | klasyczne 4-4-2 mirror; 3-back przy dobrej szerokości | ultra-def 5-4-1 (mało przestrzeni); gęste 4-5-1 |
| **4-back attack** | `4-2-4` | wysokie linie 3-back | 5-back + deep line |
| **4-back control** | `4-5-1` (szerokie/wąskie) | pressujące 4-3-3 | bezpośrednie 4-4-2 |
| **5-back** | `5-2-3`, `5-3-2`, `5-4-1` (szerokie/wąskie) | ofensywne 4-2-4 | wąskie ataki centralne; zmęczenie WB |

### Konkretne matchupy (bonus `formationMatchup`, clamp łącznie z innymi kontrami)

Tabela 1:1 z `BalanceConfig.tactics._defaultFormationMatchups` — jedyne źródło prawdy liczbowej.

| Atakująca / ustawiona formacja | Vs | Bonus (dla lewej) | Uzasadnienie |
| ------------------------------ | -- | ----------------: | ------------ |
| `4-3-3` | `4-4-2 (szerokie)` | +0,06 | szerokość vs płaska czwórka pomocy |
| `4-4-2 (szerokie)` | `3-5-2` | +0,05 | dwie dziewiątki vs 3 OB przy stałych |
| `4-5-1 (szerokie)` | `4-3-3` | +0,05 | zagęszczenie środka vs trójka pomocy |
| `3-5-2` | `4-4-2 (szerokie)` | +0,05 | przewaga liczebna w mid |
| `5-3-2` | `4-2-4` | +0,08 | blok vs overcommit |
| `5-4-1 (szerokie)` | `4-2-4` | +0,08 | blok vs overcommit |
| `4-2-4` | `3-4-3` | +0,05 | jeszcze więcej zagrożenia vs 3 OB |
| `4-2-4` | `5-4-1 (szerokie)` | +0,04 | wysokie ryzyko kontry vs niski blok |
| `5-2-3` | `4-5-1 (szerokie)` | +0,04 | trójka z przodu rozciąga gęsty mid |
| `3-4-3` | `5-3-2` | −0,06 | (kara) wąskie kanały / 5 OB |
| `4-3-3` | `5-4-1 (szerokie)` | −0,05 | (kara) mało miejsca na skrzydłach |

Pełna macierz 12×12 nie jest wymagana na start: silnik używa **rodziny + lista wyjątków**; brak wpisu = 0.

Łączny bonus kontr (formacja + ustawienia z sekcji 7) clamp: **−0,15 … +0,15**.

---

## 6. Role pozycji a działanie formacji

Każda pozycja ma role (`AssignedRole` / enumy w `enums.dart`). Role **nie zmieniają overall**, ale przesuwają wkład fazy i cechy meczowe.

### Kierunki wpływu (skrót)

| Strefa | Role „defensywne” | Role „ofensywne / kreacyjne” |
| ------ | ----------------- | ---------------------------- |
| GK | `standard` → pewność strzałów | `sweeperKeeper` → build-up, ryzyko za linią |
| CB | `noNonsenseCentreBack` → +def, bezpieczne wyclearowanie | `ballPlayingDefender` → +mid/atk z tyłu |
| FB | `defensiveFullBack` → +def | `attackingFullBack` → +atk, −def |
| WB | `wingBack` → energia flanek | `invertedWingBack` → +mid centralnie |
| CDM | `anchorMan` → +def | `regista` / `deepLyingPlaymaker` → +mid |
| CM | `ballWinning` → odbiory | `playmaker` / `mezzala` → kreacja / half-spaces |
| CAM | `playmaker` → podanie finalne | `shadowStriker` → +atk (wejścia w pole) |
| Winger | `winger` → dośrodkowania | `invertedWinger` → strzały z półprzestrzeni |
| ST | `pressingForward` → pressing | `falseNine` → +mid, tworzenie przestrzeni; `completeForward` → uniwersalny |

### Fit roli

Jeśli atrybuty zawodnika nie pasują do roli (próg fit — w kodzie):

- **OK** → mnożnik wkładu ~1,07–1,12,
- **FAIL** → ~0,80–0,90 (rola „kosztuje” więcej niż daje).

Złe role w kluczowych slotach formacji (np. trzech `attackingFullBack` w `5-4-1`) mogą **zniwelować** bazowy `def` formacji.

### Synergia ról z kształtem formacji

> Uwaga nazewnicza: to **nie** jest zgranie drużyny (`chemistry` w `squad_management.md`). Tu chodzi o to, jak role wzmacniają `def`/`mid`/`atk` formacji.

- Formacje z wysokim `mid` zyskują na `regista` / `playmaker` / `invertedWingBack`.
- Formacje z wysokim `def` zyskują na `anchorMan` / `defensiveFullBack` / `noNonsenseCentreBack`.
- Formacje z wysokim `atk` zyskają na `shadowStriker` / `invertedWinger` / `pressingForward`, ale przy słabym fit rośnie liczba strat i kartek.

---

## 7. Ustawienia taktyczne

Globalne suwaki drużyny (enumy w `enums.dart`). Modyfikują `def`/`mid`/`atk` **oraz** dodają **cechy meczowe** (osobne mnożniki w symulacji).

### Tempo (`Tempo`)

| Wartość | Δ atk | Δ mid | Δ def | Cecha meczowa |
| ------- | ----: | ----: | ----: | ------------- |
| `slow` | −4 | +3 | +2 | mniej kontr, bezpieczniejsze podania |
| `balanced` | 0 | 0 | 0 | — |
| `fast` | +6 | −3 | −4 | więcej przejść / kontr, więcej strat |

### Szerokość ataku (`AttackWidth`)

| Wartość | Δ atk | Δ mid | Δ def | Cecha |
| ------- | ----: | ----: | ----: | ----- |
| `narrow` | −2 | +2 | +1 | gra przez środek; dobre vs szerokie 3-back |
| `balanced` | 0 | 0 | 0 | — |
| `wide` | +4 | −1 | −3 | dośrodkowania / 1v1; dobre vs wąskie bloki |

### Linia obrony (`DefensiveLine`)

| Wartość | Δ def | Δ atk | Cecha |
| ------- | ----: | ----: | ----- |
| `deep` | +6 | −3 | mniej przestrzeni za plecami; słabiej vs wolne tempo rywala? (patrz kontr) |
| `normal` | 0 | 0 | — |
| `high` | −4 | +3 | offside trap / pressing; ryzyko piłek za plecy |

### Pressing (`PressingIntensity`)

| Wartość | Δ mid | Δ def | Δ atk | Cecha |
| ------- | ----: | ----: | ----: | ----- |
| `low` | −2 | +3 | −2 | oszczędza staminę; mniej fauli |
| `medium` | 0 | 0 | 0 | — |
| `high` | +2 | −2 | +1 | więcej odzyskań wyżej; ↑ faule / zmęczenie |
| `gegenpressing` | +3 | −5 | +2 | max odzyskań po stracie; ↑ kartki, ↓ stamina |

### Kontr-ustawienia (przykłady)

| Nasze | Ich | Bonus dla nas |
| ----- | --- | ------------: |
| `low` press | ich `gegenpressing` | +0,08 |
| `gegenpressing` | ich `low` | +0,06 |
| `deep` line | ich `fast` tempo | +0,05 |
| `high` line | ich `slow` tempo | +0,04 |
| `wide` | ich 3-5-2 / 3-4-3 | +0,05 |
| `narrow` | ich 4-4-2 / 4-3-3 | +0,04 |

### Stałe fragmenty (0–100)

Domyślnie 50:

- `cornersAttack` / `cornersDefense`
- `freeKicks`
- `penalties`

Wpływają tylko na eventy SFG, nie na open-play `def`/`mid`/`atk`.

---

## 8. Składanie końcowego balansu

Dla każdej drużyny przed meczem (i po pauzie / zmianie taktyki):

```text
def' = clamp( formation.def + midSlotΔ.def + tacticsΔ.def + rolesΔ.def , 0, 100 )
mid' = clamp( formation.mid + midSlotΔ.mid + tacticsΔ.mid + rolesΔ.mid , 0, 100 )
atk' = clamp( formation.atk + midSlotΔ.atk + tacticsΔ.atk + rolesΔ.atk , 0, 100 )
```

Następnie vs rywal:

```text
matchupBonus = formationRPS + tacticsCounter     // clamp −0.15…+0.15
possession   ~ f(mid_home' − mid_away', shape M)
xgChance     ~ f(atk' − opp.def', shape A vs D, matchupBonus)
```

Role działają też **per event** (kto strzela / fauluje / buduje), nie tylko przez Δ słupków.

---

## 9. UI menedżera (oczekiwane)

1. Wybór formacji → podgląd `def`/`mid`/`atk` + D–M–A.
2. Edycja slotów CDM/CM/CAM (gdzie dozwolone) → żywe Δ.
3. Ustawienia: tempo, szerokość, linia, pressing, SFG.
4. Role na XI — ostrzeżenie przy złym fit / konflikcie z filozofią formacji.
5. Podgląd „vs formacja rywala”: lekki wskaźnik przewagi / niedopasowania (bez odkrywania pełnego AI na Easy).

---

## 10. Powiązanie z AI

- Profil `cautious` → bias do wyższego `def`, `deep` / `low` press, sloty CDM.
- Profil `aggressive` → wyższy `atk`, `high` / `gegenpressing`, CAM / skrzydła.
- Hard AI: po ≥2 meczach z graczem pamięta formację / pressing i dobiera kontrę (`AI_behaviour.md`).

---

## 11. Status względem kodu

W repo mogą jeszcze nie istnieć pliki taktyki; ten dokument jest źródłem prawdy docelowej. Stałe liczbowe — w kodzie / `BalanceConfig`.
