# Wiadomości i day-to-day (inbox)

Dokument projektowy: system wiadomości oraz symulacja dzień-po-dniu w stylu **FIFA 15 Career Mode**.

Powiązane: `game_calendar.md`, `offseason.md`, `contract_signing.md`, `staff_rules.md`, `matchday_model.md`, `squad_management.md`.

Status: **projekt**.

---

## 1. Idea

Główne źródło informacji dla gracza to **inbox wiadomości**, nie rozproszone popup-y.

- Kalendarz + przycisk **symuluj dzień** (lub godzinę w oknie kontraktów).
- Każde istotne wydarzenie generuje wiadomość.
- Symulacja idzie dzień po dniu; mecze, eventy offseason i FA wpinają się w kalendarz.

---

## 2. Przepływ dnia

```text
Start dnia
  → dostarczenie zaplanowanych wiadomości / eventów dnia
  → jeśli jest wiadomość z czerwoną flagą: PAUZA + jump do inboxa
  → gracz czyta / reaguje (opcjonalnie)
  → kontynuacja: mecz / koniec dnia
  → „Symuluj” → następny dzień (lub następna godzina w trybie 10h)
```

W oknie extensions / FA: dzień = **10 godzin** — `contract_signing.md`. Po 10h = koniec dnia kalendarzowego.

---

## 3. Model wiadomości

| Pole | Opis |
| ---- | ---- |
| `id` / data / godzina | kiedy doręczono |
| `type` | enum typu (poniżej) |
| `priority` | normal / **urgent** (czerwona flaga) |
| `title` / `body` | treść |
| `payload` | linki do UI (zawodnik, mecz, oferta, prospect…) |
| `read` | przeczytana? |

### Czerwona flaga (`urgent`)

- Wstrzymuje symulację day-to-day.
- Natychmiast otwiera inbox.
- Gracz musi potwierdzić (przeczytanie / dismiss), zanim pójdzie dalej.

### Konfiguracja gracza

Gracz ustawia per `type` (lub grupa typów):

| Ustawienie | Efekt |
| ---------- | ----- |
| **Ważne** | zawsze `urgent` + pauza |
| **Normalne** | wiadomość bez pauzy |
| **Wyciszone** | brak wiadomości (lub tylko log historii — v1: brak w inboxie) |

Domyślne „Ważne” (propozycja): kontuzja XI, emerytura własna, Accept/Hard reject kluczowych negocjacji, walkower, zwolnienie HC, Scout Report dnia eventowego, Awards dotyczące własnych, utrata FA waiting.

---

## 4. Typy wiadomości (katalog)

| Typ | Przykład | Domyślnie |
| --- | -------- | --------- |
| `injury` | kontuzja / powrót | ważne jeśli XI |
| `retirementPlayer` | emerytura | ważne jeśli własny |
| `retirementStaff` | emerytura sztabu | ważne jeśli HC/Scout |
| `staffGrowth` | +0,5★ | normalne |
| `award` | MVP / TOTS / … | ważne jeśli własny |
| `lottery` | wynik loterii | ważne |
| `scoutReport` | raport okresowy / Scout Report event | konfigurowalne |
| `combine` | wyniki Combine obserwowanych | normalne / ważne |
| `mockDraft` | nowy mock | normalne |
| `draftPick` | Twój pick / AI pick | ważne na Twoim picku |
| `contractOffer` | counter / waiting / reject | ważne |
| `contractSigned` | podpis (własny lub rywal u celu) | ważne |
| `trade` | propozycja / wykonanie | ważne |
| `walkover` | roster poza 20–30 | ważne |
| `matchPreview` / `matchResult` | zapowiedź / wynik | normalne |
| `atmosphere` | kryzys szatni | normalne / ważne przy kryzysie |
| `calendar` | przypomnienie eventów | normalne |
| `system` | tutorial / błąd walidacji | wg kontekstu |

Lista rozszerzalna; nowe eventy offseason muszą dostać typ + default priority.

---

## 5. Generowanie

Zasada: **każdy event silnika → co najmniej jedna wiadomość** (chyba że typ wyciszony).

Przykłady powiązań:

- Retirements day → lista emerytów ligi + osobne ważne dla własnych.
- Scout (częstotliwość gracza) → `scoutReport` z postępem tierów.
- FA godzina → counter/accept jako `contractOffer` / `contractSigned`.
- Matchday pre-check fail → `walkover` urgent.

---

## 6. UX (szkic)

```
┌──────────────┬─────────────────────────────┐
│ Kalendarz    │ Inbox                       │
│ Dzień / event│ [!] tytuły z flagą          │
│              │ lista chronologiczna        │
│ [Symuluj]    │ podgląd treści + CTA        │
└──────────────┴─────────────────────────────┘
```

Ustawienia: zakładka „Powiadomienia” z toggles typów.

---

## 7. Status względem kodu

Brak pełnego inboxa w kodzie — dokument jest źródłem prawdy UX day-to-day. Implementacja: warstwa `simulation` + UI inbox niezależne od Flutter details w testach.
