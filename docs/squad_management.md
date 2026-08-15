# Zarządzanie składem

Dokument opisuje limity rosteru, skład meczowy oraz spójność ustawienia (lineup cohesion). 

## Limity składu

### Zasady rosteru

- Minimalna liczba zawodników w kadrze wynosi 20.
- Maksymalna liczba zawodników w kadrze to 30.
- Wszelkie operacje kontrolowane przez menedżera (draft, wolni agenci, wymiany, podpisy) muszą zawsze zamykać się w granicach od 20 do 30 gracz.
- **Nie ma mechanizmu zwolnienia zawodnika** — niekorzystny kontrakt można zdjąć wyłącznie wymianą (`salary_cap.md`, `trades.md`). Przy rosterze 30 podpisanie kolejnego zawodnika wymaga uprzedniej wymiany.
- Podpisanie kontraktu lub wymiana przekraczająca wyznaczone limity zostanie automatycznie odrzucona przez system (nie zostają nawet zsubmitowane)(chyba, że istnieje wyjątek jak przy tradzie z drużyną <20 zawodników).
- Jedyną drogą, która może spowodować spadek liczby zawodników poniżej 20, jest przejście gracza na emeryturę.

### Walkower

- Jeśli w dniu rozgrywania meczu rozmiar kadry jest mniejszy niż 20 lub większy niż 30, mecz nie zostaje rozegrany.
- Taka sytuacja skutkuje walkowerem 0-3 na korzyść drużyny przeciwnej.
- Jeśli po obu stronach występuje nielegalny roster, przyznawany jest wynik `dsq` i żadna z drużyn nie otrzymuje punktów.
- Zespół będący w takiej sytuacji otrzymuje pilną wiadomość w systemie wiadomości i musi naprawić kadrę przed kolejnymi meczami poprzez wolnych agentów, draft lub transfery.
- Porażka przez walkower bardzo pogarsza atmosferę w zespole.

### Skład meczowy

- Wyjściowa jedenastka składa się dokładnie z 11 graczy.
- Ławka rezerwowa mieści maksymalnie 7 zawodników.
- W protokole meczowym może się znaleźć łącznie 18 zawodników, które muszą pochodzić z aktywnego rosteru.
- Zawodnicy z urazami lub zawieszeniami nie mogą zostać umieszczeni w protokole meczowym.
- Zawodnicy spoza 18-osobowej kadry meczowej to rezerwa, która nie gra, ale obciąża budżet płacowy i limit rosteru.
- Zmiany w trakcie spotkania można przeprowadzać wyłącznie wykorzystując 7-osobową ławkę.
- Jeśli zespół mieści się w limicie liczebności rosteru, ale poprzez kontuzje/zawieszenia nie może zapełnić całej ławki rezerwowej to może on przystąpić do meczu - jedyna różnica to mniejsza liczba zmienników (trzeba do tego dostosować UI i komunikaty).
- Jeśli zespół mieści się w limicie liczebności rosteru, ale poprzez kontuzje/zawieszenia ma mniej niż 11 graczy zdolnych do gry to nie może on przystąpić do meczu - przyznawany jest wtedy walkower 0-3 na korzyść drużyny przeciwnej.

---

## Lineup Cohesion

Lineup cohesion to składowa opisująca współpracę oraz znajomość pozycji jedenastki meczowej. 

### Pozycje

Gra na nominalnej pozycji wpływa pozytywnie na lineup cohesion. Wystawienie gracza na obcej pozycji obniża lineup cohesion i statystyki zawodnika.

- zawodnik na obcej pozycji: -5 i mnożnik atrybutów 0,9 
- zawodnik na swojej pozycji: +2

### Role

Ustawienia zawodnika w jego optymalnej roli taktycznej daje dedykowany bonus meczowy do statystyk zawodnika oraz lineup cohesion. Ustawienie go w innej roli taktycznej nie powoduje żednego debuffa. 

- zawodnik na swojej roli: +2

| Lineup Cohesion | Mnożnik atrybutów |
| --------------- | ----------------- |
| 0–20            | 1,01              |
| 21–40           | 1,02              |
| 41–60           | 1,03              |
| 61–80           | 1,04              |
| 81–100          | 1,05              |