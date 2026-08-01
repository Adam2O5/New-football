# Model taktyczny

Dokument projektowy: formacje, balans `def` / `mid` / `atk`, kontr-formacje, role i ustawienia taktyczne w symulacji meczu.

Powiązane: `matchday_model.md`, `player_management.md`, `squad_management.md`, `AI_behaviour.md`, `enums.dart`, `tactics_balance.dart`, `formation_layout.dart`. [1]

Status: **projekt aktywny**. Źródłem danych liczbowych jest `tactics_balance.dart`, a `formation_layout.dart` odpowiada wyłącznie za wizualny układ pozycji na boisku. [1][2]

***

## 1. Idea przewodnia

Trzy twarde zależności kształtu składu pozostają bez zmian: większa liczba pomocników wzmacnia kontrolę i posiadanie, większa liczba obrońców stabilizuje blok defensywny, a większa liczba zawodników ofensywnych zwiększa zagrożenie bramkowe. [1]

Na bazę kształtu nakładają się teraz wyłącznie: baza formacji `def` / `mid` / `atk`, role zawodników na pozycjach, ustawienia taktyczne (tempo, szerokość, linia, pressing) oraz matchup formacji. Konfiguracja `MidfieldSlots` została usunięta z modelu i nie jest już osobnym wymiarem taktyki. [1]

***

## 2. Architektura danych

Warstwa taktyczna została rozdzielona na dwa obszary odpowiedzialności. `tactics_balance.dart` przechowuje wszystkie dane liczbowe i logikę balansu taktyki, natomiast `formation_layout.dart` przechowuje jedynie rozmieszczenie slotów na boisku dla UI i nie jest źródłem balansu meczu. [2]

Kluczowa konsekwencja tej zmiany: formacja nie ma już elastycznego pasa pomocy. Każda formacja definiuje z góry konkretne pozycje, np. `CDM`, `CM`, `CAM`, `LW`, `RW`, `ST`, i te pozycje wynikają bezpośrednio z wybranego presetu formacji. [2]

### Dane w `tactics_balance.dart`

| Obszar | Odpowiedzialność |
| ------ | ---------------- |
| `FormationBaseStats` | Bazowe `def` / `mid` / `atk` dla każdej formacji  |
| `TacticsDelta` | Zmiany `def` / `mid` / `atk` od ustawień typu tempo, szerokość, pressing, linia  |
| `FormationMatchup` | Bonus / kara formacji przeciw konkretnej formacji rywala  |
| `TacticsBalance` | Centralny dostęp do baz formacji, delt ustawień i matchupów  |

### Dane poza balansem

`formation_layout.dart` pozostaje warstwą prezentacyjną. Odpowiada za współrzędne anchorów i przypisanie slotów do wizualizacji, ale nie powinien przechowywać `baseDef`, `baseMid`, `baseAtk` ani innych danych wpływających na symulację. [2]

***

## 3. Lista formacji

Aktualna lista wspieranych formacji odpowiada finalnej liście z enumu `Formation`. Obejmuje 21 presetów, w tym warianty `attack`, `defend` i `wide`, które są osobnymi formacjami domenowymi, a nie modyfikacją środka pola. 

| Enum | Etykieta |
| ---- | -------- |
| `f343` | `3-4-3` |
| `f3421` | `3-4-2-1` |
| `f352` | `3-5-2` |
| `f3511` | `3-5-1-1` |
| `f41212Narrow` | `4-1-2-1-2 (narrow)` |
| `f4132` | `4-1-3-2` |
| `f4141` | `4-1-4-1` |
| `f4231` | `4-2-3-1` |
| `f4231Wide` | `4-2-3-1 (wide)` |
| `f424` | `4-2-4` |
| `f4312` | `4-3-1-2` |
| `f4321` | `4-3-2-1` |
| `f433` | `4-3-3` |
| `f433Attack` | `4-3-3 (attack)` |
| `f433Defend` | `4-3-3 (defend)` |
| `f442` | `4-4-2` |
| `f442Defend` | `4-4-2 (defend)` |
| `f451` | `4-5-1` |
| `f5212` | `5-2-1-2` |
| `f523` | `5-2-3` |
| `f532` | `5-3-2` |

Warianty takie jak `4-3-3 (attack)` i `4-3-3 (defend)` nie są już realizowane przez zmianę proporcji `CDM` / `CM` / `CAM`. Każdy z nich jest odrębną formacją z własną bazą `def` / `mid` / `atk` oraz własnym układem pozycji w layoucie. [2]

***

## 4. Kształt D–M–A

Kształt `D–M–A` nadal istnieje jako pojęcie projektowe i analityczne, ale nie jest już osobnym polem w danych balansu. Nie przechowuje się już `shapeDef`, `shapeMid` ani `shapeAtk`, ponieważ przy stałych pozycjach slotów te wartości można wyliczyć z samego składu formacji. [2]

Reguły liczenia pozostają koncepcyjnie takie same:
- **D**: CB + FB/WB ustawieni w linii obrony,
- **M**: CDM + CM + CAM + skrzydłowi ustawieni jako pomocnicy,
- **A**: ST oraz skrzydłowi ustawieni w bloku ofensywnym. [1]

To oznacza, że `D–M–A` jest teraz metryką pochodną, przydatną w UI, balansie i analizie matchupów, ale nie osobnym źródłem prawdy w modelu danych. [1]

***

## 5. Bazowe atrybuty formacji

Każda formacja ma trzy bazowe słupki faz gry: `def`, `mid`, `atk`. Są one przechowywane w `TacticsBalance._defaultFormationBaseStats` i stanowią podstawę dalszego liczenia taktyki. 

Wartości nie muszą sumować się do 100. Są niezależnymi współczynnikami jakości bloku obronnego, kontroli środka i generowania okazji. [1]

### Aktualna tabela bazowa

| Formacja | def | mid | atk | Notatka |
| -------- | --: | --: | --: | ------- |
| `3-4-3` | 42 | 55 | 68 | Bardzo ofensywna szerokość, ryzyko z tyłu.  |
| `3-4-2-1` | 46 | 64 | 60 | Dwóch kreatorów za napastnikiem, lepsza kontrola niż w `3-4-3`.  |
| `3-5-2` | 50 | 70 | 55 | Mocna kontrola środka przy umiarkowanym ataku.  |
| `3-5-1-1` | 49 | 71 | 54 | Jeszcze bardziej środkowa wersja `3-5-2`, trochę mniej bezpośrednia.  |
| `4-1-2-1-2 (narrow)` | 56 | 64 | 58 | Diament: balans środka i gry pionowej.  |
| `4-1-3-2` | 53 | 67 | 59 | Mocny środek z dwójką z przodu.  |
| `4-1-4-1` | 62 | 74 | 42 | Najbardziej kontrolna i defensywna z czwórką z tyłu.  |
| `4-2-3-1` | 56 | 68 | 57 | Elastyczny środek i dobra równowaga.  |
| `4-2-3-1 (wide)` | 53 | 62 | 64 | Mniej kontroli, więcej szerokości i wejść w atak.  |
| `4-2-4` | 40 | 45 | 75 | Ekstremalny atak kosztem kontroli i obrony.  |
| `4-3-1-2` | 52 | 65 | 61 | Wąski środek z wyraźną obecnością między liniami.  |
| `4-3-2-1` | 54 | 67 | 57 | Kontrola i półprzestrzenie bardziej niż czysta szerokość.  |
| `4-3-3` | 55 | 60 | 62 | Uniwersalna baza rodziny.  |
| `4-3-3 (attack)` | 50 | 58 | 68 | Wariant bardziej ryzykowny i wertykalny.  |
| `4-3-3 (defend)` | 61 | 58 | 55 | Wariant bezpieczniejszy, bardziej zachowawczy.  |
| `4-4-2` | 58 | 55 | 60 | Klasyczna równowaga dwóch linii i dwóch napastników.  |
| `4-4-2 (defend)` | 64 | 56 | 51 | Głębsza, bezpieczniejsza odmiana `4-4-2`.  |
| `4-5-1` | 60 | 72 | 48 | Gęsty środek i wysoka kontrola, ale mniejsze zagrożenie z przodu.  |
| `5-2-1-2` | 70 | 52 | 55 | Niski blok + CAM + dwójka z przodu.  |
| `5-2-3` | 68 | 48 | 62 | Trójka z przodu przy pięciu z tyłu.  |
| `5-3-2` | 72 | 58 | 52 | Stabilny blok z umiarkowanym wsparciem środka.  |

Te wartości są obecnie wartościami roboczymi. Zgodnie z ustaleniem nie są jeszcze finalnie zbalansowane i mogą być później strojonie na podstawie playtestów. 

***

## 6. Usunięcie `MidfieldSlots`

Model `MidfieldSlots` został usunięty z konfiguracji taktyki. Menedżer nie może już ręcznie przesuwać liczby `CDM`, `CM` i `CAM` w obrębie jednej formacji. [2]

Konsekwencje projektowe:
- nie ma już osobnych delt `midSlotΔ.def`, `midSlotΔ.mid`, `midSlotΔ.atk`, [1]
- UI nie pokazuje już edytora slotów środka pola ani podglądu zmian wynikających z przesuwania środka, [1]
- warianty takie jak ofensywny środek, diament, holding czy defensywny balans muszą być modelowane jako osobne formacje. 

To upraszcza serializację, logikę walidacji oraz spójność pomiędzy taktyką a układem pozycji na boisku. [2]

***

## 7. Ustawienia taktyczne

Globalne ustawienia drużyny pozostają osobnym wymiarem taktyki i są przechowywane jako mapy delt w `TacticsBalance`. Każde ustawienie modyfikuje `def`, `mid`, `atk` niezależnie od wybranej formacji. [1]

### Tempo (`Tempo`)

| Wartość | Δ atk | Δ mid | Δ def | Cecha meczowa |
| ------- | ----: | ----: | ----: | ------------- |
| `slow` | -4 | +3 | +2 | Mniej kontr, bezpieczniejsze podania. [1] |
| `balanced` | 0 | 0 | 0 | Wartość neutralna. [1] |
| `fast` | +6 | -3 | -4 | Więcej przejść i strat, wyższe tempo gry. [1] |

### Szerokość ataku (`AttackWidth`)

| Wartość | Δ atk | Δ mid | Δ def | Cecha |
| ------- | ----: | ----: | ----: | ----- |
| `narrow` | -2 | +2 | +1 | Gra przez środek, dobra kontra na szerokie 3-back. [1] |
| `balanced` | 0 | 0 | 0 | Wartość neutralna. [1] |
| `wide` | +4 | -1 | -3 | Więcej pojedynków 1v1 i dośrodkowań, większe ryzyko z tyłu. [1] |

### Linia obrony (`DefensiveLine`)

| Wartość | Δ def | Δ atk | Cecha |
| ------- | ----: | ----: | ----- |
| `deep` | +6 | -3 | Głębszy blok, mniej przestrzeni za plecami. [1] |
| `normal` | 0 | 0 | Wartość neutralna. [1] |
| `high` | -4 | +3 | Agresywniejsze wyjście wyżej, ryzyko piłek za linię. [1] |

### Pressing (`PressingIntensity`)

| Wartość | Δ mid | Δ def | Δ atk | Cecha |
| ------- | ----: | ----: | ----: | ----- |
| `low` | -2 | +3 | -2 | Oszczędza staminę i zmniejsza liczbę fauli. [1] |
| `medium` | 0 | 0 | 0 | Wartość neutralna. [1] |
| `high` | +2 | -2 | +1 | Więcej odzysków wysoko, ale wyższe koszty fizyczne. [1] |
| `gegenpressing` | +3 | -5 | +2 | Maksymalny nacisk po stracie, najwyższe ryzyko zmęczenia i kartek. [1] |

### Stałe fragmenty

Domyślnie 50:
- `cornersAttack`,
- `cornersDefense`,
- `freeKicks`,
- `penalties`. [1]

Wpływają na eventy SFG, ale nie zmieniają bezpośrednio bazowego `def` / `mid` / `atk` w open play. [1]

***

## 8. Matchupy formacji

Model matchupów pozostaje w systemie jako lekki bonus lub kara względem ustawienia rywala. Dane te są przechowywane w `TacticsBalance._defaultFormationMatchups`, a wynik końcowy powinien być clampowany limitem `matchupClamp`. [1]

Przykładowe relacje zachowane w modelu:
- `4-3-3` jest mocne przeciw `4-4-2`, bo szerokość ataku rozciąga płaską czwórkę pomocy, [1]
- `4-5-1` zyskuje przeciw `4-3-3`, bo zagęszcza środek pola, [1]
- `5-3-2` i warianty defensywne dobrze kontrują `4-2-4`, bo karzą overcommit w ataku, [1]
- `3-4-3` traci przeciw zwartym 5-backom, gdy brakuje przestrzeni w kanałach. [1]

Macierz matchupów nie jest kompletna dla wszystkich 21 formacji i nadal powinna być traktowana jako robocza. W praktyce system może działać na zasadzie: rodzina + wyjątki, a brak wpisu oznacza 0. [1]

***

## 9. Role pozycji

Każda pozycja ma role (`AssignedRole` / enumy w `enums.dart`) i role nadal przesuwają wkład faz gry, ale nie zmieniają `overall`. Nadal obowiązuje zasada, że defensywne role wzmacniają `def`, kreatywne i wertykalne wzmacniają `mid` lub `atk`, a słaby fit roli obniża efektywność zawodnika. [1]

Przykłady kierunku wpływu:
- `anchorMan`, `defensiveFullBack`, `noNonsenseCentreBack` wzmacniają stabilność bloku, [1]
- `regista`, `playmaker`, `invertedWingBack` pomagają formacjom opartym o kontrolę środka, [1]
- `shadowStriker`, `invertedWinger`, `pressingForward` podbijają kreację i presję w wysokim ataku. [1]

To nie jest to samo co zgranie drużyny (`chemistry`). Chodzi o dopasowanie roli do filozofii konkretnej formacji i profilu zawodnika. [1]

***

## 10. Składanie końcowego balansu

Po usunięciu `MidfieldSlots` końcowy balans drużyny przed meczem upraszcza się do modelu:

```text
def' = clamp( formation.def + tacticsΔ.def + rolesΔ.def , 0, 100 )
mid' = clamp( formation.mid + tacticsΔ.mid + rolesΔ.mid , 0, 100 )
atk' = clamp( formation.atk + tacticsΔ.atk + rolesΔ.atk , 0, 100 )
```

Następnie kontra rywala:

```text
matchupBonus = formationRPS + tacticsCounter     // clamp −0.15…+0.15
possession   ~ f(mid_home' − mid_away', derived shape M)
xgChance     ~ f(atk' − opp.def', derived shape A vs D, matchupBonus)
```

Najważniejsza różnica względem starego modelu polega na usunięciu komponentu `midSlotΔ`. Każda zmiana charakteru środka pola musi teraz wynikać z wyboru innej formacji albo z ról i ustawień drużyny. [1]

***

## 11. UI menedżera

Oczekiwany interfejs po zmianach:
1. wybór formacji,
2. podgląd `def` / `mid` / `atk`,
3. ustawienia: tempo, szerokość, linia, pressing, SFG,
4. role na XI i ostrzeżenia o złym fit,
5. lekki wskaźnik matchup advantage vs rywal. [1]

Usunięty zostaje krok edycji `CDM` / `CM` / `CAM` w ramach jednej formacji. Jeżeli użytkownik chce bardziej defensywnego lub ofensywnego środka, powinien wybrać inny preset formacji, np. `4-3-3`, `4-3-3 (attack)` albo `4-3-3 (defend)`. [1]

***

## 12. Powiązanie z AI

Założenia wysokiego poziomu pozostają takie same: profile AI typu `cautious` powinny preferować wyższe `def`, głębszą linię i niższy pressing, natomiast profile agresywne powinny częściej wybierać ustawienia zwiększające `atk`, pressing i ryzyko. Po usunięciu `MidfieldSlots` AI nie przesuwa już środka pola w ramach jednej formacji, tylko wybiera odpowiedni preset formacji i zestaw ustawień. [1]

***

## 13. Status względem kodu

Aktualny kierunek implementacyjny jest następujący:
- `tactics_balance.dart` jest źródłem prawdy dla liczbowej warstwy taktyki, 
- `formation_layout.dart` jest źródłem prawdy wyłącznie dla warstwy wizualnej, [2]
- `MidfieldSlots` i wynikające z niego modyfikatory zostały wycofane z modelu, [2]
- część liczb i matchupów ma nadal status roboczy i wymaga strojenia podczas playtestów.