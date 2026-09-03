class MessageTextTemplate {
  const MessageTextTemplate({
    required this.key,
    required this.title,
    required this.body,
  });

  final String key;
  final String title;
  final String body;
}

class MessageTemplatesPl {
  static const Map<String, MessageTextTemplate> templates = {
    'msg_walkover_title': MessageTextTemplate(
      key: 'msg_walkover_title',
      title: 'Zagrożenie walkowerem',
      body:
          'Nie możesz rozegrać meczu zgodnie z regulaminem. Powód: {reason}. Uzupełnij skład przed spotkaniem z {opponentName}, aby uniknąć walkowera.',
    ),
    'msg_lineupNoGk_title': MessageTextTemplate(
      key: 'msg_lineupNoGk_title',
      title: 'Brak bramkarza w składzie',
      body:
          'Aktualny skład na mecz z {opponentName} nie zawiera dostępnego bramkarza. Ustaw co najmniej jednego zdrowego golkipera w wyjściowej jedenastce lub na ławce.',
    ),
    'msg_benchIncomplete_title': MessageTextTemplate(
      key: 'msg_benchIncomplete_title',
      title: 'Niepełna ławka rezerwowych',
      body:
          'Ławka rezerwowych przed meczem z {opponentName} jest niekompletna. Masz obsadzonych tylko {currentBenchCount} z {requiredBenchCount} wymaganych miejsc.',
    ),
    'msg_suspensionStart_title': MessageTextTemplate(
      key: 'msg_suspensionStart_title',
      title: 'Zawieszenie zawodnika',
      body:
          '{playerName} został zawieszony na {matches} mecz(e). Powód: {reason}.',
    ),
    'msg_suspensionEnd_title': MessageTextTemplate(
      key: 'msg_suspensionEnd_title',
      title: 'Koniec zawieszenia',
      body:
          '{playerName} zakończył odbywanie kary i jest ponownie dostępny do gry.',
    ),
    'msg_injury_title': MessageTextTemplate(
      key: 'msg_injury_title',
      title: 'Kontuzja zawodnika',
      body:
          '{playerName} doznał urazu: {injuryName}. Przewidywana przerwa potrwa {recoveryTime} dni. Status medyczny: {severity}.',
    ),
    'msg_injuryReturn_title': MessageTextTemplate(
      key: 'msg_injuryReturn_title',
      title: 'Powrót po kontuzji',
      body:
          '{playerName} zakończył rehabilitację po urazie {injuryName} i może wrócić do treningów oraz kadry meczowej.',
    ),
    'msg_injuryRecurrence_title': MessageTextTemplate(
      key: 'msg_injuryRecurrence_title',
      title: 'Nawrót kontuzji',
      body:
          'U {playerName} doszło do nawrotu urazu: {injuryName}. Nowy przewidywany czas przerwy wynosi {recoveryTime} dni.',
    ),
    'msg_potentialLoss_title': MessageTextTemplate(
      key: 'msg_potentialLoss_title',
      title: 'Spadek potencjału',
      body:
          '{playerName} może stracić część potencjału rozwojowego w wyniku odniesionej kontuzji.',
    ),
    'msg_playerEvent_plateau_title': MessageTextTemplate(
      key: 'msg_playerEvent_plateau_title',
      title: 'Zastój w rozwoju',
      body:
          '{playerName} wszedł w okres stagnacji. Sztab sugeruje zmianę planu treningowego lub większą cierpliwość, aby przerwać zastój.',
    ),
    'msg_playerEvent_coldStreak_title': MessageTextTemplate(
      key: 'msg_playerEvent_coldStreak_title',
      title: 'Słabsza forma zawodnika',
      body:
          '{playerName} notuje wyraźny spadek formy. Możesz podtrzymać zaufanie lub ograniczyć jego rolę do czasu poprawy dyspozycji.',
    ),
    'msg_playerEvent_injuryComplication_title': MessageTextTemplate(
      key: 'msg_playerEvent_injuryComplication_title',
      title: 'Powikłania po urazie',
      body:
          'Proces leczenia zawodnika {playerName} nie przebiega idealnie. Decyzja dotyczy tempa powrotu do gry i ryzyka pogłębienia problemu.',
    ),
    'msg_playerEvent_veteranMotivation_title': MessageTextTemplate(
      key: 'msg_playerEvent_veteranMotivation_title',
      title: 'Motywacja weterana',
      body:
          '{playerName} oczekuje jasnego sygnału co do swojej roli w drużynie. Odpowiednia reakcja może poprawić jego morale i zaangażowanie.',
    ),
    'msg_playerEvent_extraTraining_title': MessageTextTemplate(
      key: 'msg_playerEvent_extraTraining_title',
      title: 'Prośba o dodatkowy trening',
      body:
          '{playerName} chce wejść w dodatkowy cykl treningowy. Może to przyspieszyć rozwój, ale zwiększa też obciążenie organizmu.',
    ),
    'msg_playerEvent_personalSupport_title': MessageTextTemplate(
      key: 'msg_playerEvent_personalSupport_title',
      title: 'Potrzeba wsparcia',
      body:
          '{playerName} zmaga się z problemami poza boiskiem i oczekuje wsparcia ze strony klubu. Reakcja może wpłynąć na morale oraz formę.',
    ),
    'msg_playerEvent_breakthrough_title': MessageTextTemplate(
      key: 'msg_playerEvent_breakthrough_title',
      title: 'Przełom w rozwoju',
      body: '{playerName} wykonał wyraźny krok naprzód w ostatnim okresie.',
    ),
    'msg_playerEvent_personalProblems_title': MessageTextTemplate(
      key: 'msg_playerEvent_personalProblems_title',
      title: 'Problemy osobiste',
      body:
          '{playerName} przechodzi trudniejszy okres poza futbolem. Może to chwilowo obniżyć jego koncentrację i dyspozycję meczową.',
    ),
    'msg_playerEvent_lateBloomer_title': MessageTextTemplate(
      key: 'msg_playerEvent_lateBloomer_title',
      title: 'Późny rozkwit talentu',
      body:
          '{playerName} rozwija się lepiej, niż wcześniej zakładano. Warto ponownie ocenić jego rolę i potencjał w projekcie sportowym.',
    ),
    'msg_playerEvent_nationalTeam_title': MessageTextTemplate(
      key: 'msg_playerEvent_nationalTeam_title',
      title: 'Powołanie do reprezentacji',
      body:
          '{playerName} otrzymał powołanie do reprezentacji narodowej. To może podnieść prestiż zawodnika, ale zwiększy też obciążenie.',
    ),
    'msg_playerEvent_inspiredPerformance_title': MessageTextTemplate(
      key: 'msg_playerEvent_inspiredPerformance_title',
      title: 'Zawodnik na fali',
      body:
          '{playerName} jest w znakomitym momencie formy. Ostatnie występy sugerują, że warto utrzymać go w ważnej roli.',
    ),
    'msg_teamEvent_moreMinutesRequest_title': MessageTextTemplate(
      key: 'msg_teamEvent_moreMinutesRequest_title',
      title: 'Prośba o więcej minut',
      body:
          '{playerName} uważa, że zasługuje na większą rolę w zespole. Oczekuje deklaracji dotyczącej liczby minut i miejsca w rotacji.',
    ),
    'msg_teamEvent_transferRequestI_title': MessageTextTemplate(
      key: 'msg_teamEvent_transferRequestI_title',
      title: 'Prośba o transfer',
      body:
          '{playerName} po raz pierwszy poprosił o zgodę na odejście z klubu. Powód: {reason}. Twoja decyzja wpłynie na atmosferę w szatni.',
    ),
    'msg_teamEvent_transferRequestII_title': MessageTextTemplate(
      key: 'msg_teamEvent_transferRequestII_title',
      title: 'Ponowiona prośba o transfer',
      body:
          '{playerName} ponowił prośbę o transfer i oczekuje konkretnej reakcji. Dalsze ignorowanie sytuacji może pogorszyć jego nastawienie.',
    ),
    'msg_teamEvent_dressingRoomConflict_title': MessageTextTemplate(
      key: 'msg_teamEvent_dressingRoomConflict_title',
      title: 'Konflikt w szatni',
      body:
          'W zespole pojawił się konflikt pomiędzy {personA} i {personB}. Sztab oczekuje decyzji, czy interweniować, czy pozwolić sytuacji wygasnąć.',
    ),
    'msg_teamEvent_publicCriticism_title': MessageTextTemplate(
      key: 'msg_teamEvent_publicCriticism_title',
      title: 'Publiczna krytyka',
      body:
          '{playerName} publicznie skomentował sytuację w klubie. Musisz zdecydować, czy odpowiedzieć, ukarać zawodnika, czy zignorować sprawę.',
    ),
    'msg_teamEvent_declineToExtend_title': MessageTextTemplate(
      key: 'msg_teamEvent_declineToExtend_title',
      title: 'Brak chęci przedłużenia umowy',
      body:
          '{playerName} nie jest obecnie zainteresowany przedłużeniem kontraktu.',
    ),
    'msg_teamEvent_leaderSupport_title': MessageTextTemplate(
      key: 'msg_teamEvent_leaderSupport_title',
      title: 'Wsparcie lidera',
      body:
          '{playerName} publicznie wsparł decyzje sztabu i pomógł uspokoić nastroje w drużynie. Morale zespołu może na tym skorzystać.',
    ),
    'msg_teamEvent_promiseBroken_title': MessageTextTemplate(
      key: 'msg_teamEvent_promiseBroken_title',
      title: 'Niedotrzymana obietnica',
      body:
          'Jedna z obietnic złożonych zawodnikowi {playerName} nie została spełniona. Może to odbić się na morale, relacjach i chęci pozostania w klubie.',
    ),
    'msg_teamEvent_atmosphereShift_title': MessageTextTemplate(
      key: 'msg_teamEvent_atmosphereShift_title',
      title: 'Zmiana atmosfery w drużynie',
      body:
          'W szatni nastąpiła zauważalna zmiana nastrojów. Warto sprawdzić, co stoi za tą zmianą.',
    ),
    'msg_retirementPlayer_title': MessageTextTemplate(
      key: 'msg_retirementPlayer_title',
      title: 'Zawodnik kończy karierę',
      body:
          '{playerName} ogłosił zakończenie kariery po sezonie {seasonLabel}. Klub powinien rozpocząć planowanie zastępstwa.',
    ),
    'msg_retirementStaff_title': MessageTextTemplate(
      key: 'msg_retirementStaff_title',
      title: 'Członek sztabu kończy pracę',
      body:
          '{staffName}, pełniący rolę {staffRole}, ogłosił odejście po sezonie {seasonLabel}. Warto przygotować plan sukcesji.',
    ),
    'msg_retirementLeagueDigest_digest_title': MessageTextTemplate(
      key: 'msg_retirementLeagueDigest_digest_title',
      title: 'Podsumowanie emerytur w lidze',
      body:
          'W tygodniu {week} zakończenie kariery ogłosiło {count} osób w całej lidze. Sprawdź zbiorczy raport, aby ocenić wpływ na rynek.',
    ),
    'msg_rosterWarning_title': MessageTextTemplate(
      key: 'msg_rosterWarning_title',
      title: 'Problem z kadrą',
      body:
          'Twoja kadra nie spełnia obecnie wymogów regulaminowych. Szczegół problemu: {reason}. Aktualny stan: {currentCount}. Wymagany zakres: {requiredRange}.',
    ),
    'msg_contractOffer_title': MessageTextTemplate(
      key: 'msg_contractOffer_title',
      title: 'Aktualizacja negocjacji kontraktowych',
      body:
          'W negocjacjach z {subjectName} pojawiła się nowa informacja. Sprawdź szczegóły oferty i zdecyduj o dalszych krokach.',
    ),
    'msg_contractOffer_accept_title': MessageTextTemplate(
      key: 'msg_contractOffer_accept_title',
      title: 'Oferta została zaakceptowana',
      body:
          '{subjectName} zaakceptował warunki kontraktu. Ustalona długość umowy: {years} lat(a), wynagrodzenie: {salary}. Pozostało sfinalizować podpis.',
    ),
    'msg_contractOffer_reject_title': MessageTextTemplate(
      key: 'msg_contractOffer_reject_title',
      title: 'Oferta została odrzucona',
      body:
          '{subjectName} odrzucił Twoją propozycję kontraktu. Powód odrzucenia: {reason}. Możesz wrócić z nową ofertą.',
    ),
    'msg_contractOffer_hardReject_title': MessageTextTemplate(
      key: 'msg_contractOffer_hardReject_title',
      title: 'Twarde odrzucenie oferty',
      body:
          '{subjectName} zdecydowanie odrzucił propozycję i nie chce obecnie kontynuować rozmów. Powód: {reason}.',
    ),
    'msg_contractOffer_waiting_title': MessageTextTemplate(
      key: 'msg_contractOffer_waiting_title',
      title: 'Oczekiwanie na decyzję',
      body:
          '{subjectName} wstrzymuje się z odpowiedzią na ofertę. Zawodnik lub agent potrzebuje więcej czasu na ocenę sytuacji rynkowej.',
    ),
    'msg_contractOffer_counter_title': MessageTextTemplate(
      key: 'msg_contractOffer_counter_title',
      title: 'Kontroferta kontraktowa',
      body:
          '{subjectName} przedstawił kontrofertę. Oczekiwana długość umowy: {years} lat(a), oczekiwane wynagrodzenie: {salary}, dodatkowe warunki: {extraTerms}.',
    ),
    'msg_contractOffer_rfaQualifyingOffer_title': MessageTextTemplate(
      key: 'msg_contractOffer_rfaQualifyingOffer_title',
      title: 'Kwalifikująca oferta dla RFA',
      body:
          'Musisz zdecydować, czy złożyć qualifying offer dla {subjectName} przed końcem okna {extensionWindowEnd}. Złożenie oferty pozwoli zachować kontrolę nad statusem RFA.',
    ),
    'msg_contractOfferResponse_title': MessageTextTemplate(
      key: 'msg_contractOfferResponse_title',
      title: 'Odpowiedź na ofertę kontraktową',
      body:
          'Otrzymano nową odpowiedź w sprawie oferty dla {subjectName}. Sprawdź szczegóły negocjacji.',
    ),
    'msg_contractOfferResponse_accept_title': MessageTextTemplate(
      key: 'msg_contractOfferResponse_accept_title',
      title: 'Akceptacja odpowiedzi kontraktowej',
      body:
          '{subjectName} zaakceptował przedstawione warunki. Możesz przejść do finalizacji umowy.',
    ),
    'msg_contractOfferResponse_reject_title': MessageTextTemplate(
      key: 'msg_contractOfferResponse_reject_title',
      title: 'Odrzucenie odpowiedzi kontraktowej',
      body: '{subjectName} odrzucił ostatnią propozycję. Powód: {reason}.',
    ),
    'msg_contractOfferResponse_hardReject_title': MessageTextTemplate(
      key: 'msg_contractOfferResponse_hardReject_title',
      title: 'Zamknięcie rozmów kontraktowych',
      body:
          '{subjectName} definitywnie kończy obecny etap negocjacji. Dalsze próby w tym momencie są bardzo mało prawdopodobne.',
    ),
    'msg_contractOfferResponse_waiting_title': MessageTextTemplate(
      key: 'msg_contractOfferResponse_waiting_title',
      title: 'Negocjacje w zawieszeniu',
      body:
          '{subjectName} wciąż analizuje sytuację i nie podjął decyzji. Na razie rozmowy pozostają otwarte.',
    ),
    'msg_contractOfferResponse_counter_title': MessageTextTemplate(
      key: 'msg_contractOfferResponse_counter_title',
      title: 'Nowa kontroferta',
      body:
          '{subjectName} wrócił z nową propozycją: {years} lat(a), {salary}, warunki dodatkowe: {extraTerms}.',
    ),
    'msg_contractSigned_title': MessageTextTemplate(
      key: 'msg_contractSigned_title',
      title: 'Podpisano kontrakt',
      body:
          '{subjectName} podpisał kontrakt z klubem {teamName}. Długość umowy: {years} lat(a), wartość: {salary}.',
    ),
    'msg_contractExpiring_player_title': MessageTextTemplate(
      key: 'msg_contractExpiring_player_title',
      title: 'Wygasający kontrakt zawodnika',
      body:
          'Umowa zawodnika {subjectName} wygasa po sezonie {seasonLabel}. To dobry moment, aby rozpocząć rozmowy lub przygotować alternatywy.',
    ),
    'msg_contractExpiring_staff_title': MessageTextTemplate(
      key: 'msg_contractExpiring_staff_title',
      title: 'Wygasający kontrakt członka sztabu',
      body:
          'Kontrakt osoby {subjectName} na stanowisku {staffRole} wygasa po sezonie {seasonLabel}. Rozważ przedłużenie lub zmianę obsady.',
    ),
    'msg_contractLostToRival_lostToRival_title': MessageTextTemplate(
      key: 'msg_contractLostToRival_lostToRival_title',
      title: 'Cel negocjacji wybrał inny klub',
      body:
          '{subjectName} podpisał kontrakt z klubem {winnerTeamName}. Twoja oferta przestała być aktualna.',
    ),
    'msg_contractExpired_player_title': MessageTextTemplate(
      key: 'msg_contractExpired_player_title',
      title: 'Kontrakt wygasł',
      body:
          'Umowa zawodnika {subjectName} z klubem {teamName} wygasła. Status zawodnika zmienił się zgodnie z zasadami rynku kontraktowego.',
    ),
    'msg_contractExpired_staff_title': MessageTextTemplate(
      key: 'msg_contractExpired_staff_title',
      title: 'Wygasła umowa członka sztabu',
      body:
          'Umowa osoby {subjectName} pełniącej rolę {staffRole} w klubie {teamName} dobiegła końca.',
    ),
    'msg_declineToExtend_title': MessageTextTemplate(
      key: 'msg_declineToExtend_title',
      title: 'Odmowa przedłużenia kontraktu',
      body:
          '{subjectName} nie chce obecnie rozmawiać o przedłużeniu umowy. Powód: {reason}.',
    ),
    'msg_rfaOfferSheet_title': MessageTextTemplate(
      key: 'msg_rfaOfferSheet_title',
      title: 'Offer sheet dla RFA',
      body:
          '{subjectName} otrzymał offer sheet od klubu {rivalTeamName}. Musisz zdecydować, czy wyrównać ofertę: {salary} na {years} lat(a).',
    ),
    'msg_staffOfferResponse_title': MessageTextTemplate(
      key: 'msg_staffOfferResponse_title',
      title: 'Odpowiedź na ofertę dla sztabu',
      body:
          'Otrzymano odpowiedź w negocjacjach z {subjectName}. Sprawdź szczegóły propozycji.',
    ),
    'msg_staffOfferResponse_accept_title': MessageTextTemplate(
      key: 'msg_staffOfferResponse_accept_title',
      title: 'Sztab zaakceptował ofertę',
      body:
          '{subjectName} zaakceptował ofertę objęcia roli {staffRole} w Twoim klubie.',
    ),
    'msg_staffOfferResponse_reject_title': MessageTextTemplate(
      key: 'msg_staffOfferResponse_reject_title',
      title: 'Sztab odrzucił ofertę',
      body:
          '{subjectName} odrzucił ofertę pracy na stanowisku {staffRole}. Powód: {reason}.',
    ),
    'msg_staffOfferResponse_hardReject_title': MessageTextTemplate(
      key: 'msg_staffOfferResponse_hardReject_title',
      title: 'Definitywna odmowa sztabu',
      body:
          '{subjectName} stanowczo zamknął rozmowy i nie jest zainteresowany dalszymi negocjacjami.',
    ),
    'msg_staffOfferResponse_waiting_title': MessageTextTemplate(
      key: 'msg_staffOfferResponse_waiting_title',
      title: 'Sztab czeka z decyzją',
      body:
          '{subjectName} potrzebuje więcej czasu na ocenę oferty i innych możliwości.',
    ),
    'msg_staffOfferResponse_counter_title': MessageTextTemplate(
      key: 'msg_staffOfferResponse_counter_title',
      title: 'Kontroferta członka sztabu',
      body:
          '{subjectName} przesłał kontrofertę dotyczącą roli {staffRole}. Oczekiwane warunki: {salary} oraz {extraTerms}.',
    ),
    'msg_staffOfferResponse_lostToRival_title': MessageTextTemplate(
      key: 'msg_staffOfferResponse_lostToRival_title',
      title: 'Kandydat do sztabu wybrał rywala',
      body:
          '{subjectName} dołączył do klubu {winnerTeamName}, dlatego rozmowy z Twoją drużyną zostały zakończone.',
    ),
    'msg_staffSigned_title': MessageTextTemplate(
      key: 'msg_staffSigned_title',
      title: 'Podpisano członka sztabu',
      body:
          '{subjectName} oficjalnie dołączył do klubu {teamName} jako {staffRole}.',
    ),
    'msg_staffGrowth_title': MessageTextTemplate(
      key: 'msg_staffGrowth_title',
      title: 'Rozwój członka sztabu',
      body:
          '{subjectName} poprawił ocenę kompetencji w obszarze {focusArea}. Aktualny wzrost: {growthValue}.',
    ),
    'msg_staffHired_title': MessageTextTemplate(
      key: 'msg_staffHired_title',
      title: 'Nowy członek sztabu',
      body: 'Klub zatrudnił {subjectName} na stanowisku {staffRole}.',
    ),
    'msg_staffFired_title': MessageTextTemplate(
      key: 'msg_staffFired_title',
      title: 'Rozstanie ze sztabem',
      body:
          '{subjectName} przestał pełnić funkcję {staffRole} w klubie {teamName}.',
    ),
    'msg_staffSlotEmpty_title': MessageTextTemplate(
      key: 'msg_staffSlotEmpty_title',
      title: 'Wolny etat w sztabie',
      body:
          'Stanowisko {staffRole} pozostaje nieobsadzone. Brak tej roli może osłabić funkcjonowanie klubu.',
    ),
    'msg_trade_title': MessageTextTemplate(
      key: 'msg_trade_title',
      title: 'Aktualizacja wymiany',
      body:
          'Pojawiła się nowa wiadomość dotycząca wymiany z klubem {otherTeamName}.',
    ),
    'msg_tradeOffer_title': MessageTextTemplate(
      key: 'msg_tradeOffer_title',
      title: 'Nowa oferta wymiany',
      body:
          'Klub {otherTeamName} przesłał ofertę wymiany. Termin odpowiedzi: {tradeOfferExpiry}.',
    ),
    'msg_trade_counter_title': MessageTextTemplate(
      key: 'msg_trade_counter_title',
      title: 'Kontroferta wymiany',
      body: 'Klub {otherTeamName} odpowiedział kontrofertą.',
    ),
    'msg_trade_accepted_title': MessageTextTemplate(
      key: 'msg_trade_accepted_title',
      title: 'Wymiana zaakceptowana',
      body: 'Wymiana z klubem {otherTeamName} została zaakceptowana.',
    ),
    'msg_trade_rejected_title': MessageTextTemplate(
      key: 'msg_trade_rejected_title',
      title: 'Wymiana odrzucona',
      body: 'Klub {otherTeamName} odrzucił propozycję wymiany.',
    ),
    'msg_trade_hardRejected_title': MessageTextTemplate(
      key: 'msg_trade_hardRejected_title',
      title: 'Stanowcze odrzucenie wymiany',
      body:
          'Klub {otherTeamName} stanowczo odrzucił ofertę wymiany i nie chce wracać do tego pakietu w obecnej formie.',
    ),
    'msg_trade_ntcRefusal_title': MessageTextTemplate(
      key: 'msg_trade_ntcRefusal_title',
      title: 'Klauzula NTC zablokowała wymianę',
      body:
          '{subjectName} skorzystał z prawa no-trade clause i zablokował wymianę do klubu {otherTeamName}.',
    ),
    'msg_trade_leagueDigest_title': MessageTextTemplate(
      key: 'msg_trade_leagueDigest_title',
      title: 'Skrót wymian w lidze',
      body: 'W tygodniu {week} w lidze doszło do wymian zawodników.',
    ),
    'msg_tradeWindowEvent_open_title': MessageTextTemplate(
      key: 'msg_tradeWindowEvent_open_title',
      title: 'Otwarcie okna transferowego',
      body:
          'Okno transferowe zostało otwarte. Od teraz możesz rozpoczynać i finalizować wymiany zgodnie z regulaminem.',
    ),
    'msg_tradeWindowEvent_deadline_title': MessageTextTemplate(
      key: 'msg_tradeWindowEvent_deadline_title',
      title: 'Deadline wymian',
      body:
          'Zbliża się lub właśnie nadszedł termin zamknięcia okna transferowego. Dopilnuj wszystkich aktywnych rozmów przed deadlinem.',
    ),
    'msg_lottery_title': MessageTextTemplate(
      key: 'msg_lottery_title',
      title: 'Wyniki loterii draftu',
      body:
          'Loteria draftu została rozstrzygnięta. Klub {teamName} otrzymał pick numer {pickNumber}.',
    ),
    'msg_scoutReport_title': MessageTextTemplate(
      key: 'msg_scoutReport_title',
      title: 'Raport skautingu',
      body:
          'Dostępny jest nowy raport skautingu. Zakres raportu: {summary}. Najważniejszy obserwowany zawodnik: {playerName}.',
    ),
    'msg_scoutReport_monthly_title': MessageTextTemplate(
      key: 'msg_scoutReport_monthly_title',
      title: 'Miesięczny raport skautingu',
      body:
          'Sztab skautingu przygotował miesięczne podsumowanie postępów. Liczba zaktualizowanych profili: {count}.',
    ),
    'msg_scoutReport_event_title': MessageTextTemplate(
      key: 'msg_scoutReport_event_title',
      title: 'Raport skautingu na event',
      body:
          'Przed wydarzeniem draftowym pojawił się specjalny raport skautingu. Zawiera kluczowe informacje o obserwowanych prospektach: {summary}.',
    ),
    'msg_combine_title': MessageTextTemplate(
      key: 'msg_combine_title',
      title: 'Wyniki combine',
      body:
          'Opublikowano wyniki testów combine. Wyróżniony prospekt: {playerName}. Najważniejszy wynik: {summary}.',
    ),
    'msg_mockDraft_title': MessageTextTemplate(
      key: 'msg_mockDraft_title',
      title: 'Nowy mock draft',
      body:
          'Pojawiła się zaktualizowana prognoza draftu. Sprawdź przewidywane wybory i ruchy zawodników na tablicach.',
    ),
    'msg_mockDraft_initial_title': MessageTextTemplate(
      key: 'msg_mockDraft_initial_title',
      title: 'Pierwszy mock draft',
      body:
          'Opublikowano pierwszy mock draft w tym cyklu. To wstępny obraz rynku i pozycji prospektów.',
    ),
    'msg_mockDraft_final_title': MessageTextTemplate(
      key: 'msg_mockDraft_final_title',
      title: 'Ostatni mock draft',
      body:
          'To finalna prognoza przed draftem. Warto porównać ją z własną tablicą i raportami skautów.',
    ),
    'msg_draftPick_title': MessageTextTemplate(
      key: 'msg_draftPick_title',
      title: 'Wybór w drafcie',
      body:
          'W drafcie wykonano wybór numer {pickNumber}. Wybrany zawodnik: {playerName}, klub: {teamName}.',
    ),
    'msg_draftPick_own_title': MessageTextTemplate(
      key: 'msg_draftPick_own_title',
      title: 'Twój wybór w drafcie',
      body:
          'Nadeszła kolej na Twój pick numer {pickNumber}. Czas podjąć decyzję i wybrać zawodnika z dostępnej tablicy.',
    ),
    'msg_draftPickLeague_league_title': MessageTextTemplate(
      key: 'msg_draftPickLeague_league_title',
      title: 'Wybory w lidze',
      body:
          'W rundzie {round} inne kluby dokonały kolejnych wyborów. Skrót najważniejszych picków: {summary}.',
    ),
    'msg_draftedRightsReminder_title': MessageTextTemplate(
      key: 'msg_draftedRightsReminder_title',
      title: 'Przypomnienie o prawach do zawodnika',
      body:
          'Nadal posiadasz prawa do zawodnika {playerName}. Aktualna liczba miejsc w kadrze: {rosterCount}. Sprawdź, czy chcesz go podpisać lub zachować prawa na później.',
    ),
    'msg_apronWarning_title': MessageTextTemplate(
      key: 'msg_apronWarning_title',
      title: 'Ostrzeżenie budżetowe',
      body:
          'Klub przekroczył próg {thresholdName}. Aktualne wydatki płacowe wynoszą {currentPayroll}. Może to ograniczyć dostępne ruchy kadrowe.',
    ),
    'msg_capUpdateTv_title': MessageTextTemplate(
      key: 'msg_capUpdateTv_title',
      title: 'Aktualizacja salary cap',
      body:
          'Nowa prognoza wpływów telewizyjnych zmieniła parametry finansowe ligi. Zaktualizowany cap na sezon {seasonLabel}: {newCap}.',
    ),
    'msg_staffCapViolation_title': MessageTextTemplate(
      key: 'msg_staffCapViolation_title',
      title: 'Przekroczony limit kosztów sztabu',
      body:
          'Koszt zatrudnienia sztabu przekracza dozwolony limit. Aktualny poziom: {currentValue}, limit: {capValue}.',
    ),
    'msg_award_title': MessageTextTemplate(
      key: 'msg_award_title',
      title: 'Nagroda sezonowa',
      body:
          'Przyznano nowe wyróżnienie sezonowe. Laureat: {playerName}, klub: {teamName}.',
    ),
    'msg_award_mvp_title': MessageTextTemplate(
      key: 'msg_award_mvp_title',
      title: 'MVP sezonu',
      body: '{playerName} z klubu {teamName} zdobył nagrodę MVP sezonu.',
    ),
    'msg_award_roty_title': MessageTextTemplate(
      key: 'msg_award_roty_title',
      title: 'Debiutant sezonu',
      body:
          '{playerName} z klubu {teamName} został wybrany debiutantem sezonu.',
    ),
    'msg_award_dpoy_title': MessageTextTemplate(
      key: 'msg_award_dpoy_title',
      title: 'Obrońca sezonu',
      body:
          '{playerName} z klubu {teamName} zdobył nagrodę dla najlepszego defensora sezonu.',
    ),
    'msg_award_coachOfYear_title': MessageTextTemplate(
      key: 'msg_award_coachOfYear_title',
      title: 'Trener roku',
      body:
          '{playerName} związany z klubem {teamName} otrzymał wyróżnienie Trenera Roku.',
    ),
    'msg_award_topScorer_title': MessageTextTemplate(
      key: 'msg_award_topScorer_title',
      title: 'Król strzelców',
      body:
          '{playerName} z klubu {teamName} zakończył sezon jako najlepszy strzelec.',
    ),
    'msg_award_topAssist_title': MessageTextTemplate(
      key: 'msg_award_topAssist_title',
      title: 'Lider asyst',
      body:
          '{playerName} z klubu {teamName} zanotował najwięcej asyst w sezonie.',
    ),
    'msg_award_bestGk_title': MessageTextTemplate(
      key: 'msg_award_bestGk_title',
      title: 'Najlepszy bramkarz',
      body:
          '{playerName} z klubu {teamName} został uznany za najlepszego bramkarza sezonu.',
    ),
    'msg_award_teamOfSeason_title': MessageTextTemplate(
      key: 'msg_award_teamOfSeason_title',
      title: 'Drużyna sezonu',
      body: '{playerName} trafił do drużyny sezonu.',
    ),
    'msg_award_champion_title': MessageTextTemplate(
      key: 'msg_award_champion_title',
      title: 'Mistrz ligi',
      body: 'Klub {teamName} sięgnął po mistrzostwo ligi.',
    ),
    'msg_atmosphere_title': MessageTextTemplate(
      key: 'msg_atmosphere_title',
      title: 'Atmosfera w zespole',
      body:
          'W szatni odnotowano zmianę atmosfery. Aktualny status: {status}. Główny powód: {reason}.',
    ),
    'msg_teamStatusChange_title': MessageTextTemplate(
      key: 'msg_teamStatusChange_title',
      title: 'Zmiana statusu drużyny',
      body:
          'Status sportowy lub organizacyjny klubu uległ zmianie z {oldStatus} na {newStatus}.',
    ),
    'msg_seasonSummary_title': MessageTextTemplate(
      key: 'msg_seasonSummary_title',
      title: 'Podsumowanie sezonu',
      body:
          'Sezon {seasonLabel} dobiegł końca. Bilans drużyny: {record}. Najważniejsze osiągnięcia: {summary}.',
    ),
    'msg_playoffMissed_title': MessageTextTemplate(
      key: 'msg_playoffMissed_title',
      title: 'Poza fazą play-off',
      body:
          'Klub {teamName} nie zakwalifikował się do fazy play-off w sezonie {seasonLabel}.',
    ),
    'msg_playoffSeeding_title': MessageTextTemplate(
      key: 'msg_playoffSeeding_title',
      title: 'Ustalono rozstawienie play-off',
      body:
          'W konferencji {conference} drużyny z miejsc 7 i 8 to odpowiednio {seed7} oraz {seed8}. Rozstawienie fazy posezonowej zostało potwierdzone.',
    ),
    'msg_playInResult_title': MessageTextTemplate(
      key: 'msg_playInResult_title',
      title: 'Wynik turnieju play-in',
      body:
          'W konferencji {conference} miejsca premiowane awansem uzyskały zespoły {seed7} i {seed8}.',
    ),
    'msg_calendar_title': MessageTextTemplate(
      key: 'msg_calendar_title',
      title: 'Przypomnienie kalendarza',
      body:
          'Nadchodzi wydarzenie: {eventName}. Data: {eventDate}. Warto przygotować się z wyprzedzeniem.',
    ),
    'msg_calendar_newWeek_title': MessageTextTemplate(
      key: 'msg_calendar_newWeek_title',
      title: 'Nowy tydzień',
      body: 'Rozpoczął się tydzień {week} sezonu (faza: {phase}).',
    ),
    'msg_system_title': MessageTextTemplate(
      key: 'msg_system_title',
      title: 'Komunikat systemowy',
      body: '{message}',
    ),
    'msg_ovrDigest_digest_title': MessageTextTemplate(
      key: 'msg_ovrDigest_digest_title',
      title: 'Tygodniowy raport zmian overalli',
      body:
          'W tygodniu {week} odnotowano {count} zmian overalli wśród obserwowanych lub własnych zawodników. Sprawdź raport zbiorczy, aby zobaczyć szczegóły.',
    ),
  };
}
