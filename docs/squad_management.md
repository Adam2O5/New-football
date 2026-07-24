# Zarządzanie składem (squad management)

Dokument projektowy: limity rosteru, skład meczowy, atmosfera i zgranie.

Powiązane: `player_management.md`, `tactics.md`, `matchday_model.md`, `staff_rules.md`, `trade_rules.md`, `salary_cap_rules.md`.

Status: **projekt**.

---

## 1. Limity składu

### Roster (cały zespół)

| Reguła | Wartość |
| ------ | ------- |
| Minimalna liczba zawodników | **20** |
| Maksymalna liczba zawodników | **30** |
| Minimum bramkarzy | **brak** (nie wymuszamy liczby GK w kadrze) |

- Operacje **kontrolowane** (draft, FA, trade, zwolnienie, podpis) muszą zostawić `20 ≤ rosterSize ≤ 30`. Trade / podpis poza limitem = **odrzucenie**.
- **Jedyna** droga poza 20–30: **emerytura** zawodników (`offseason.md`). Wówczas roster może być &lt; 20 (lub teoretycznie &gt; 30 nie występuje przy samym odjęciu).
- Seed / nowa kariera: domyślnie **25** zawodników; zalecany ≥ 1 GK, bez twardego wymogu.

### Walkower (nielegalny roster na mecz)

Jeśli w dniu meczu `rosterSize < 20` lub `rosterSize > 30`:

- Mecz **nie jest rozgrywany** — wynik **walkower 0–3** na korzyść przeciwnika.
- Obie strony nielegalne → **0–0**, bez punktów (lub anulowanie — v1: 0–0, 0 pkt).
- Wiadomość z czerwoną flagą — `messages.md`.
- Naprawa: FA / draft / trade do przywrócenia 20–30 przed kolejnymi meczami.

### Bramkarz po emeryturze

Po emeryturze ostatniego / kluczowego BR klub ma czas **do startu tyg. 1** na podpisanie następcy. Brak BR w kadrze **nie** blokuje offseasonu; w meczu bez `Position.gk` w bramce obowiązuje kara wyniku — `matchday_model.md` (to **nie** jest walkower rosteru).

### Skład meczowy (matchday)

| Element | Liczba |
| ------- | -----: |
| Wyjściowa jedenastka (XI) | **11** |
| Ławka rezerwowa | **7** |
| Razem w protokole | **18** |

- XI + ławka ⊆ roster; zawodnicy kontuzjowani / zawieszeni nie mogą wejść do protokołu (chyba że osobna reguła ligi).
- Pozostali członkowie rosteru (do 12 przy max 30) to **rezerwa poza meczem** — nie grają, ale liczą się do limitu 20–30 i payroll.
- Zmiany w trakcie meczu: tylko z 7-osobowej ławki (`matchday_model.md`).

---

## 2. Atmosfera i zgranie — przegląd

Każdy zespół ma dwa powiązane wskaźniki (skala **0–100**):

| Wskaźnik | EN (kod) | Opis |
| -------- | -------- | ---- |
| **Atmosfera** | `atmosphere` / morale szatni | nastroje, zadowolenie, „klimat” w klubie |
| **Zgranie** | `chemistry` | jak dobrze skład współpracuje na boisku i w schemacie |

Relacja dwukierunkowa:

```text
słaba atmosfera  ──►  obniża zgranie (z czasem)
dobra atmosfera  ──►  podnosi zgranie (z czasem)
wysokie zgranie  ──►  lekko wspiera atmosferę (stabilizacja)
```

Aktualizacja: co mecz / co tydzień (do ustalenia w silniku day-to-day); zmiany są **stopniowe** (np. ±1…3 pkt), nie skoki ±30 po jednym wyniku.

---

## 3. Atmosfera (`atmosphere`)

### Co na nią wpływa

| Czynnik | Kierunek | Uwagi |
| ------- | -------- | ----- |
| **Zgranie** | wysokie ↑ / niskie ↓ | feedback loop ze sekcji 2 |
| **Forma zespołu** | seria zwycięstw ↑, porażek ↓ | forma = wyniki z ostatnich N meczów (+ ewentualnie miejsce w tabeli vs oczekiwania) |
| **Respektowanie próśb zawodników** | spełnione ↑ / zignorowane ↓ | prośby: więcej minut, trade, rola, przedłużenie, transfer out itd. |

Dodatkowe (lżejsze) źródła — spójne z `matchday_model.md` / osobowościami:

- obecność `leader` w XI / szatni → lekki bonus,
- konflikty `temperamental`, złamane obietnice kontraktowe → kara,
- sztab / styl trenera zgodny z szatnią → lekki bonus (`staff_rules.md`).

### Skutki atmosfery

| Poziom | Zakres (przykład) | Efekt |
| ------ | ----------------- | ----- |
| Kryzys | 0–29 | mocny dren zgrania; ↑ szansa próśb / trade demand; w meczu ↑ błędy / kartki nerwowe |
| Słaba | 30–49 | powolny spadek zgrania; gorsza motywacja |
| Neutralna | 50–69 | brak silnego dryfu |
| Dobra | 70–84 | powolny wzrost zgrania |
| Świetna | 85–100 | szybszy wzrost zgrania; bonus morale w meczu |

Niska atmosfera **obniża zgranie**; wysoka **je polepsza** — to główny most między szatnią a boiskiem.

---

## 4. Zgranie (`chemistry`)

### Co buduje zgranie

Ważne: do zgrania liczy się **optymalna pozycja**, **nie** optymalna rola.

| Czynnik | Opis |
| ------- | ---- |
| **Optymalne pozycje w XI** | zawodnik na swojej `Position` (lub akceptowanej secondary — jeśli odblokowana) ↑; gra „nie na swojej” pozycji ↓ |
| **Czas razem** | `seasonsWithTeam` + wspólne mecze w XI; nowi transfery startują z karą „adaptacji” |
| **Osobowość** | kompatybilność w szatni (np. wielu `leader` / `professional` ↑; skupisko `temperamental` ↓); zgodność z trenerem |
| **Trenerzy / sztab** | rating Defense/Offense + match stylu gry ze składem (`staff_rules.md`) |
| **Wspólna narodowość** | pary / klastry tej samej `Nationality` w XI dają bonus linków (nie wymaga całej drużyny z jednego kraju) |
| **Atmosfera** | dryf w górę/dół jak w sekcji 3 |

### Czego zgranie **nie** myli z rolą

- Ustawienie `AssignedRole` (np. `falseNine` vs `pressingForward`) **nie** jest warunkiem zgrania.
- Rola daje **osobny boost meczowy** (sekcja 6), niezależny od chemistry.

### Skutki zgrania — atrybuty

Zgranie modyfikuje **efektywne** atrybuty jawne (FUT) / wkład w meczu — nie nadpisuje permanentnie zapisanych 50–99.

```text
effectiveAttr = round( baseAttr × chemistryMult )
chemistryMult ∈ [0.92 … 1.08]     // przykład; clamp w kodzie
```

| Zgranie | `chemistryMult` (projekt) | Efekt |
| ------- | ------------------------: | ----- |
| 0–29 | 0,92–0,95 | wyraźne obniżenie |
| 30–49 | 0,95–0,98 | lekkie obniżenie |
| 50–69 | ~1,00 | baseline |
| 70–84 | 1,02–1,05 | lekki boost |
| 85–100 | 1,05–1,08 | silny boost |

Wysokie zgranie **zwiększa** atrybuty (efektywne); niskie **obniża**.  
Overall UI może pokazywać bazowy overall + strzałkę / tint „chemii”, żeby nie mylić z developmentem.

Dodatkowo w symulacji (`matchday_model.md`): wysokie zgranie → lepsze podania / mniej chaosu przy pressingu.

---

## 5. Pozycja vs rola — rozróżnienie

| Pojęcie | Wpływa na | Gdy OK | Gdy źle |
| ------- | --------- | ------ | ------- |
| **Pozycja** (`Position`) | zgranie drużyny + ewentualna twarda kara contribution | buduje chemistry | drenuje chemistry, gorszy wkład |
| **Rola** (`AssignedRole`) | osobny mnożnik statystyk / contribution | **boost do statystyk** | brak boostu lub kara fit (patrz `tactics.md`) |

Przykład: LW wystawiony jako ST → kara pozycji (zgranie ↓).  
ST z rolą `completeForward` przy dobrym fit → boost roli, nawet jeśli zgranie drużyny jest średnie.

---

## 6. Boost optymalnej roli

Zawodnik w XI (lub wchodzący z ławki) na **optymalnej roli** względem pozycji i atrybutów:

```text
roleMult ≈ 1,05 … 1,12   // gdy fit ≥ próg
roleMult ≈ 0,80 … 0,90   // gdy rola niepasująca (FAIL)
roleMult = 1,00          // rola „standard” / neutralna
```

- Boost dotyczy **efektywnych** statystyk w meczu (i ewentualnie widocznego „in-form role” w UI).
- Stackowanie z chemią:

```text
matchAttr = baseAttr × chemistryMult × roleMult
```

(z clampem per atrybut, np. 40–99, żeby nie wybuchać ponad skalę FUT).

Szczegóły progów fit: `tactics.md` §6.

---

## 7. Prośby zawodników (wpływ na atmosferę)

Typowe prośby (przykłady):

- więcej minut / miejsce w XI,
- zmiana pozycji / rola (tu: prośba o rolę **nie** buduje zgrania sama z siebie — tylko morale po spełnieniu),
- przedłużenie kontraktu / podwyżka,
- transfer / trade out,
- obiecanie walki o tytuł / draft pick protection itd.

| Reakcja menedżera | Atmosfera |
| ----------------- | --------- |
| Spełnienie w terminie | ↑ |
| Częściowe spełnienie | lekki ↑ lub 0 |
| Ignorowanie / złamanie obietnicy | ↓ (silniej u `ambitious` / `temperamental`) |
| Spełnienie u `loyal` | mniejszy bonus (i tak stabilni); złamanie i tak boli mniej niż u innych |

---

## 8. Walidacja i operacje rosterowe

| Operacja | Warunek |
| -------- | ------- |
| Trade | po ruchu **obie** strony: 20–30; inaczej trade **odrzucony** (`trade_rules.md`) |
| FA / draft / podpis / zwolnienie | po ruchu: 20–30 (podpis blokowany jeśli &gt; 30; zwolnienie blokowane jeśli &lt; 20 — wyjątek: emerytura omija blokadę) |
| Emerytura | może zejść poniżej 20; skutek: walkower do naprawy |
| Cap / apron | osobno — `salary_cap_rules.md` |
| Ustawienie XI | dokładnie 11 dostępnych; formacja z `tactics.md`; slot BR ideally `gk` |
| Ławka | do 7 z pozostałych dostępnych |

---

## 9. Podsumowanie zależności

```text
prośby + forma zespołu + zgranie ──► atmosphere
atmosphere (dryf) + pozycje XI + czas razem
  + osobowości + trenerzy + narodowość ──► chemistry
chemistry ──► effective FUT attrs (× 0.92…1.08)
optymalna rola ──► dodatkowy roleMult (× ~1.05…1.12)
pozycja ≠ rola
```

---

## 10. Status względem kodu

- Roster seed ≈ 25; limity 20–30 i ławka 7 wymagają walidacji w modelu / UI (bez min. GK).
- `Team` ma `roster` + `lineupPlayerIds`; brak jeszcze pól `atmosphere` / `chemistry` i ławki 7.
- Ten dokument jest źródłem prawdy projektowej; stałe liczbowe — w kodzie / `BalanceConfig`.
