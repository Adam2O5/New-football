# Odbiór wydajności na Androidzie — przygotowanie

Stan z 30 października 2026: **profil urządzenia odłożony na później na decyzję użytkownika**. Lokalny build `flutter build apk --profile` zakończył się kodem 0. Kompilacja `assembleProfile` trwała 123,9 s. Build nie jest pomiarem działania aplikacji.

## Przygotowany artefakt

- APK: `build/app/outputs/flutter-apk/app-profile.apk`.
- Rozmiar: 105345987 bajtów.
- SHA-256: `9f1dd9e8c6cc0f42f8179e683a0d80648151a39b5757ac4481d4952ff5a87461`.
- Pełny lokalny log: `build/android-profile-build.log`.
- Flutter 3.41.4, Dart 3.11.1, aplikacja 1.0.0+1. Build lokalny; bez publikacji i produkcyjnego podpisywania.
- Pliki w `build/` są ignorowane i mogą zniknąć po czyszczeniu. Po zmianie kodu lub narzędzi skompilować nowy APK i zapisać nowy hash.

W chwili sprawdzenia `flutter devices --machine` pokazał Windows i Edge; nie wykrył Androida. Nie instalowano ani nie uruchamiano APK na telefonie. Nie zmieniano ustawień urządzeń ani danych istniejących karier.

## Co już sprawdzono lokalnie

- [Save/load/rename/duplicate](save-pipeline-baseline-2026-10-30.md): dwa wolumeny danych.
- [Komendy Inbox i normalizacja](controller-normalization-baseline-2026-10-30.md): 1 i 30 drużyn.
- [Dzień i transport workera](simulation-pipeline-baseline-2026-10-30.md): 1 i 5 dni, bez meczów i decyzji AI.
- [Gotowe operacje rynku](contract-market-baseline-2026-10-30.md): FA-I, kontrolowany waiting i podpis oraz oddzielna diagnostyka indeksu.

Wyniki Flutter test/JIT opisują kontrolowane scenariusze desktopowe. Ich liczby nie stanowią budżetów dla Androida i nie potwierdzają płynności mobilnej. Lista testów long jest w [isolated_suites.md](isolated_suites.md).

## Warunki rozpoczęcia odbioru

1. Udostępnić fizyczny telefon z debugowaniem USB i autoryzować połączenie na urządzeniu. Sprawdzić jego identyfikator przez `flutter devices`. Emulator może służyć do smoke, ale wynik oznaczyć jako emulator i nie używać go do odbioru wydajności docelowego telefonu.
2. Zapisać model, wersję Androida, pamięć urządzenia, częstotliwość odświeżania ekranu, stan zasilania i wersje narzędzi. Porównania prowadzić w podobnych warunkach obciążenia i temperatury.
3. Zapisać commit/binary hash oraz używany stan kariery. Skorzystać z dedykowanej kariery testowej, zamiast resetować dane użytkownika. Jeśli UI nie pozwala ustawić seedu, zachować ten sam zapis wejściowy i jego seed; nie dopisywać w tym celu debugowych elementów UI do produktu.
4. Wybrać cel pomiaru: czas odpowiedzi na komendę, płynność w trakcie symulacji, opóźnienie zapisu lub zużycie pamięci. Budżet klatki wynika z rzeczywistej częstotliwości ekranu; nie stosować z góry jednego progu do wszystkich telefonów.

## Uruchomienie i nagranie

Z katalogu projektu:

```powershell
flutter devices
flutter run --profile -d IDENTYFIKATOR_ANDROID
```

W miejsce `IDENTYFIKATOR_ANDROID` wpisać faktyczny identyfikator telefonu. Otworzyć DevTools z adresu udostępnionego dla tej sesji i użyć widoków Performance/Memory. Samo zainstalowanie APK i sprawdzenie, że się otwiera, jest wyłącznie smoke; profil wymaga nagrania scenariuszy.

Dla każdego scenariusza zapisać pierwsze wykonanie osobno i co najmniej pięć kolejnych prób na równoważnym stanie. Oddzielić czas świadomego pacingu kalendarza i oczekiwanie na interakcję od kosztu CPU/I/O. Testy long z `test/performance/long/` pozostają harnessami desktopowymi — powyższe polecenie nie zamienia ich w testy integracyjne na Androidzie.

## Scenariusze do nagrania

### A. Responsywność komend i ekranów

Oznaczenie zwykłej wiadomości jako przeczytanej, zmiana zakładki składu/tabeli i powrót do Inbox. Sprawdzić czas reakcji i klatki UI/raster, w tym czy nie występuje niepotrzebna odbudowa ukrytych ekranów. DevTools pokazuje efekt aplikacji, a nie automatycznie osobne czasy prywatnych metod; jeżeli do identyfikacji kosztu będą potrzebne znaczniki Timeline, dodać je dopiero jako osobną, świadomą zmianę diagnostyczną.

### B. Kalendarz i worker

Pojedynczy dzień oraz krótka seria na zachowanym zapisie. Mierzyć do rzeczywistego punktu zatrzymania (wiadomość, zdarzenie lub mecz); nie utożsamiać takiego zatrzymania z wykonaniem całej zamierzonej serii. Odnotować liczbę faktycznie wykonanych dni i zawartość scenariusza. Dnia z meczem lub odroczoną decyzją AI nie porównywać liczbowo z lekkim fixture’em bez meczów z baseline’u.

### C. Zapis i odczyt

Save/load oraz zmiana nazwy i duplikacja dla zachowanego zapisu. Sprawdzić responsywność UI podczas pracy, poprawność wyniku po zakończeniu i pamięć przed/po operacji. Rozdzielić opublikowanie stanu od zakończenia trwałego zapisu. Nie wywoływać utraty procesu na osobistej karierze w ramach tego odbioru.

### D. Ręczny rynek

W oknie godzinowym użyć zachowanego stanu i wykonać ofertę, rozstrzygnięcie oczekiwania oraz finalizację, jeśli dany przebieg rzeczywiście prowadzi do tych stanów. Zapisać liczbę klubów, graczy, wolnych agentów i negocjacji. Nie zastępować tego kalibracją autonomicznego AI.

## Format wyniku i decyzja

Wynik powinien zawierać: środowisko, commit/hash, opis wejścia, liczbę operacji/prób, pierwsze wykonanie, medianę/min/max kolejnych prób, czasy klatek względem odświeżania oraz zapis śladu Performance i obserwacje Memory. Przy pięciu próbkach nie raportować p95. RSS procesu, rozmiar sterty i alokacje mają różne znaczenia — oznaczać je zgodnie z narzędziem, które je zmierzyło.

Odbiór kończy się decyzją dla konkretnego problemu: koszt akceptowalny, wymagana optymalizacja z budżetem i śladem albo brak wystarczających danych. Dopiero istotny koszt związany z normalizacją uzasadnia rozpoczęcie warunkowego etapu 4. Udany build i pomiary desktopowe nie zastępują tej decyzji.

Kolejne niezależne prace po tej części planu: build Android w CI, odtwarzalność generatorów i zawężenie wyjątków kontroli źródeł. Nie zostały wdrożone w pakiecie pomiarowym.
