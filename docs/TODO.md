# TODO — V1.0

## UI i UX
- [x] Dopracować `StaffScreen` oraz pełny przepływ slotów, ofert i negocjacji sztabu.
- [x] Dokończyć UX i weryfikację przepływu `Draft Combine`.
- [x] Rozszerzyć testy widgetowe o pozostałe krytyczne ścieżki UI (w szczególności matchday, inbox, trade, kontrakty, draft i walidację składu) — zrealizowano w Task 41.

## AI i walidacja
- [ ] Domknąć kalibrację AI na 10 sezonach: naprawić accelerated runner, uzyskać raport 17 metryk i powtórzyć smoke test full-fidelity — testy uruchamiać przez `scripts/test.ps1`.
- [ ] Zweryfikować statystycznie jakość draftu bez scouta, brak walkowerów AI oraz realizację obietnic po uzyskaniu raportu kalibracyjnego — testy uruchamiać przez `scripts/test.ps1`.
- [ ] Nie wykonywać tuningu AI bez raportu; jeśli raport wykaże odchylenia, stroić parametry w kolejności opisanej w Task 38.

## Lokalizacja i dokumentacja
- [x] Dokończyć audyt kompletności i spójności lokalizacji PL/EN oraz uzupełnić ewentualne brakujące napisy — guard `test/data/task42_audit_test.dart` potwierdza identyczne klucze i placeholdery.
- [x] Wykonać testy strażnicze i końcowy audyt dokumentacji zgodnie z Task 42 — zrealizowano w Task 42.

## Zasada
- Pozycje już zrealizowane — finanse, wspólne tło i styl, Home, Squad/roster, ustawienia i zapis w Shell, autosave taktyki, draft, lottery, prospects, rankings, rewards, stats, development, FA, contracts, draft history, search, playoff/play-in w standings, chemistry/atmosphere, trades, salary cap, random events i scouting — nie są powtarzane jako TODO.
