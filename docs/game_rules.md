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
- W razie remisu jest dogrywka i ewentualne karne
- Łącznie 16 drużyn w playoff (8 per konferencja)

## Playoff
- Format BO5 (do 3 wygranych)
- W razie remisu w game 5 jest dogrywka i ewentualne karne
- Seeding: 1v8, 4v5, 2v7, 3v6
- Finał konferencji → finał ligi

## Draft
- 3 rundy; pula **120** prospektów; generacja **po drafcie** na klasę N+1
- Loteria dla dolnych **10** drużyn; mock wstępny + mock finalny — `draft.md`
- Rookie scale contracts; ROTY = cała klasa draftowa poprzedniego roku

## Salary Cap / finanse
- Limit uzgadniany **co 5–7 lat** przy nowej umowie TV (termin znany przy podpisaniu) — `salary_cap.md`
- Cap bazowy **350M €**; 1st apron **396,7M**; 2nd apron **431,7M**
- Pensja zawodnika: min **1M €**, max **60M €**
- Rookie scale `baseScale` **8M**; RFA = QO + prawo match — `contracts.md`
- **V1 nie ma budżetu operacyjnego ani podatku od luksusu** — jedynym skutkiem przekroczenia capu są ograniczenia w wymianach i podpisach
- **Nie ma możliwości zwolnienia zawodnika ani członka sztabu** — niekorzystny kontrakt można zdjąć wyłącznie wymianą
- Osobny **staff salary cap** **15M €** (6 slotów, pensja 0,5–5M) — `staff.md`, `salary_cap.md`

## Trades
- Wymiana zawodników i picków draftowych — główny sposób przebudowy składu poza draftem i wolnymi agentami.
- Szczegóły: `trades.md` (tylko wymiany 2-drużynowe; okno od końca playoff do trade deadline tyg. 23; odrzut przy wyjściu poza 20–30)

## Skład
- Roster **20–30** (bez min. liczby GK); XI 11 + ławka 7 — `squad_management.md`
- Roster poza limitem na mecz → walkower 0–3; brak GK w bramce → kara wyniku ~0–5 — `matchday_model.md`
- Lineup cohesion — `squad_management.md`
- Team status, expected rank, atmosfera i zgranie — `team_management.md`

## Zawodnik
- Atrybuty FUT, potencjał ★, `overallProgress`, `growthRate`, kontuzje, emerytury 33+ — `player_management.md`

## Taktyka
- Formacje (`def`/`mid`/`atk`), role, pressing, kontr-formacje — `tactics.md`

## Matchday
- Symulacja minuta-po-minucie (UX jak FIFA 15 + pauza / zmiany) — `matchday_model.md`

## AI / sztab
- **Jeden model AI** (V1) — bez poziomów trudności i profili menedżera; AI działa na identycznych regułach co gracz — `AI_behaviour.md`
- Sztab: Head Coach, Development Coach, Scout, Physio, Doctor, CFO (★ 0–5) — `staff.md`

## Offseason / draft / FA
- Terminy i reguły eventów: `offseason.md`, `game_calendar.md`
- Draft: `draft.md`
- Negocjacje 10h/dzień: `contracts.md`

## Wiadomości / day-to-day
- Inbox jak FIFA 15, czerwone flagi, konfiguracja ważności — `messages.md`

## Kalendarz / offseason
- `game_calendar.md`, `offseason.md`
