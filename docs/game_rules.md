# Reguły gry — New Football Manager

## Liga
- 30 drużyn w 2 konferencjach, po 15 drużyn
- Sezon regularny: 58 meczów (double round robin, każdy z każdym 2×)

## Play-in (per konferencja)
- Miejsca 1–6: awans automatyczny do playoff
- Miejsca 7–10: play-in BO1
  - Mecz 1: 7 vs 8
  - Mecz 2: 9 vs 10
  - Mecz 3: przegrany(7/8) vs wygrany(9/10)
- Łącznie 16 drużyn w playoff (8 per konferencja)

## Playoff
- Format BO5 (do 3 wygranych)
- Seeding: 1v8, 4v5, 2v7, 3v6
- Finał konferencji → finał ligi

## Draft
- 3 rundy; pula **120** prospektów; generacja **po drafcie** na klasę N+1
- Loteria dla dolnych **10** drużyn; mock wstępny + mock finalny — `draft_rules.md`
- Rookie scale contracts; ROTY = cała klasa draftowa poprzedniego roku

## Salary Cap / finanse
- Limit uzgadniany **co 5–7 lat** przy nowej umowie TV (termin znany przy podpisaniu) — `salary_cap_rules.md`
- Cap bazowy **300M €**; 1st apron **340M**; 2nd apron **370M**; luxury tax 1,75 / 2,25 / 3,00
- Rookie scale `baseScale` **8M**; MLE reset przy FA (tyg. 47); RFA = QO + prawo match
- Budżet operacyjny `cashBalance` (osobny od capu) — luxury tax płatny z cash
- Osobny **staff salary cap** — `staff_rules.md`

## Trades
- Wymiana zawodników i picków draftowych — główny sposób przebudowy składu poza draftem i wolnymi agentami.
- Szczegóły: `trade_rules.md` (tylko wymiany 2-drużynowe; okno od końca playoff do trade deadline tyg. 23; odrzut przy wyjściu poza 20–30)

## Skład
- Roster **20–30** (bez min. liczby GK); XI 11 + ławka 7 — `squad_management.md`
- Roster poza limitem na mecz → walkower 0–3; brak GK w bramce → kara wyniku ~0–5 — `matchday_model.md`
- Atmosfera i zgranie — `squad_management.md`

## Zawodnik
- Atrybuty FUT, potencjał ★, `overallProgress`, `growthRate`, kontuzje, emerytury 33+ — `player_management.md`

## Taktyka
- Formacje (`def`/`mid`/`atk`), role, pressing, kontr-formacje — `tactics.md`

## Matchday
- Symulacja minuta-po-minucie (UX jak FIFA 15 + pauza / zmiany) — `matchday_model.md`

## AI / sztab
- Poziomy **Normal** / **Hard** oraz profile menedżera — `AI_behaviour.md`
- Sztab: HC, Youth, Scout, Physio, Doctor, CFO (★ 0–5) — `staff_rules.md`

## Offseason / draft / FA
- Terminy i reguły eventów: `offseason.md`, `game_calendar.md`
- Draft: `draft_rules.md`
- Negocjacje 10h/dzień: `contract_signing.md`

## Wiadomości / day-to-day
- Inbox jak FIFA 15, czerwone flagi, konfiguracja ważności — `messages.md`

## Kalendarz / offseason
- `game_calendar.md`, `offseason.md`
