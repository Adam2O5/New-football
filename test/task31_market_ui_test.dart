import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/screens/contract_screen.dart';
import 'package:new_football/app/screens/free_agency_screen.dart';
import 'package:new_football/app/screens/staff_screen.dart';
import 'package:new_football/app/screens/trade_history_screen.dart';
import 'package:new_football/core/models/contract_market_models.dart';
import 'package:new_football/core/models/contract_negotiation.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/models/trade_models.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

void main() {
  testWidgets(
    'historia wymian sortuje wpisy, filtruje wynik i rozwija szczegóły',
    (tester) async {
      final fixture = _fixture();
      await tester.pumpWidget(_app(const TradeHistoryScreen(), fixture.league));
      await tester.pump();

      final tiles = tester.widgetList<ExpansionTile>(
        find.byType(ExpansionTile),
      );
      expect(tiles, hasLength(2));
      expect((tiles.first.subtitle! as Text).data, contains('tydzień 20'));
      expect(find.text('Brak zgodności salary cap'), findsNothing);

      await tester.tap(find.byType(ExpansionTile).first);
      await tester.pumpAndSettle();

      expect(find.text('Powód: Brak zgodności salary cap'), findsOneWidget);
      expect(find.text('Prawdopodobieństwo zgody NTC: 42.0%'), findsOneWidget);
      expect(find.text('Zawodnik: Task 31 Roster Player'), findsOneWidget);
      expect(find.text('Pick: 2027, runda 1'), findsOneWidget);

      await tester.tap(find.byType(DropdownButtonFormField<String?>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Odrzucona'));
      await tester.pumpAndSettle();

      expect(find.byType(ExpansionTile), findsOneWidget);
      expect(find.text('Odrzucona'), findsOneWidget);
      expect(find.textContaining('Zaakceptowana'), findsNothing);
    },
  );

  testWidgets(
    'kontrakty pokazują godzinę rynku, preview oferty oraz rundę z deadline',
    (tester) async {
      final fixture = _fixture();
      await tester.pumpWidget(_app(const ContractScreen(), fixture.league));
      await tester.pump();

      expect(find.text('Wolna agentura — faza I'), findsOneWidget);
      expect(find.textContaining('Godzina ofert: 1/10'), findsOneWidget);
      await tester.drag(_verticalScrollable(), const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(find.textContaining('Runda 2'), findsOneWidget);
      expect(find.text('Oczekuje na odpowiedź na kontrofertę'), findsOneWidget);
      expect(find.textContaining('Termin: tydz. 47'), findsWidgets);

      await tester.drag(_verticalScrollable(), const Offset(0, 600));
      await tester.pumpAndSettle();
      await tester.tap(find.text(fixture.marketPlayer.name).first);
      await tester.pump();

      expect(
        find.text('Podgląd oferty: ${fixture.marketPlayer.name}'),
        findsOneWidget,
      );
      expect(find.textContaining('Oczekiwana pensja:'), findsWidgets);
      expect(find.textContaining('Oczekiwana długość:'), findsWidgets);
      expect(find.textContaining('Wynik oferty:'), findsWidgets);
    },
  );

  testWidgets('FA I pokazuje zegar, sztab i aktywny przycisk Match', (
    tester,
  ) async {
    final fixture = _fixture();
    await tester.pumpWidget(_app(const FreeAgencyScreen(), fixture.league));
    await tester.pump();

    expect(find.text('Wolna agentura — faza I'), findsOneWidget);
    expect(find.textContaining('Godzina ofert: 1/10'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text(fixture.staffCandidate.name),
      400,
      scrollable: _verticalScrollable(),
    );
    expect(find.text('Dostępny sztab'), findsOneWidget);
    expect(find.text(fixture.staffCandidate.name), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Wyrównaj'),
      400,
      scrollable: _verticalScrollable(),
    );
    expect(find.text('Offer sheets RFA'), findsOneWidget);

    final matchButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Wyrównaj'),
    );
    expect(matchButton.onPressed, isNotNull);
  });

  testWidgets('FA II nie pokazuje godzinowego zegara ofert', (tester) async {
    final fixture = _fixture(currentWeek: 48, currentHour: null);
    await tester.pumpWidget(_app(const FreeAgencyScreen(), fixture.league));
    await tester.pump();

    expect(find.text('Wolna agentura — faza II'), findsOneWidget);
    expect(find.textContaining('Godzina ofert:'), findsNothing);
  });

  testWidgets('Match jest ukryty po terminie offer sheetu RFA', (tester) async {
    final fixture = _fixture(currentDay: 2, currentHour: 2, sheetExpiryHour: 1);
    await tester.pumpWidget(_app(const FreeAgencyScreen(), fixture.league));
    await tester.pump();

    await tester.scrollUntilVisible(
      find.text('Offer sheets RFA'),
      500,
      scrollable: _verticalScrollable(),
    );
    expect(find.text('Offer sheets RFA'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Wyrównaj'), findsNothing);
    expect(
      find.text('Dziś nie jest otwarte żadne okno kontraktowe.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'sztab pokazuje kandydatów, preview oferty i blokuje zatrudnienie po użyciu godziny',
    (tester) async {
      final fixture = _fixture(hourlyStaffOfferUsed: true);
      await tester.pumpWidget(_app(const StaffScreen(), fixture.league));
      await tester.pump();

      expect(find.text('Wolna agentura — faza I'), findsOneWidget);
      expect(find.textContaining('Godzina ofert: 1/10'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text(fixture.staffCandidate.name),
        400,
        scrollable: _verticalScrollable(),
      );
      await tester.tap(find.text(fixture.staffCandidate.name));
      await tester.pump();

      expect(
        find.text('Podgląd oferty: ${fixture.staffCandidate.name}'),
        findsOneWidget,
      );
      expect(find.textContaining('Oczekiwana pensja:'), findsOneWidget);
      expect(find.textContaining('Oczekiwana długość:'), findsOneWidget);
      expect(find.textContaining('Wynik oferty:'), findsOneWidget);

      final hireButtons = tester
          .widgetList<FilledButton>(
            find.widgetWithText(FilledButton, 'Zatrudnij'),
          )
          .toList();
      expect(hireButtons, isNotEmpty);
      for (final button in hireButtons) {
        expect(button.onPressed, isNull);
      }
      expect(
        find.text('Dziś nie jest otwarte żadne okno kontraktowe.'),
        findsWidgets,
      );
    },
  );
}

class _MarketFixture {
  const _MarketFixture({
    required this.league,
    required this.marketPlayer,
    required this.staffCandidate,
  });

  final LeagueState league;
  final Player marketPlayer;
  final StaffMember staffCandidate;
}

_MarketFixture _fixture({
  int currentWeek = 47,
  int currentDay = 1,
  int? currentHour = 1,
  int sheetExpiryDay = 2,
  int sheetExpiryHour = 2,
  bool hourlyStaffOfferUsed = false,
}) {
  final game = GameFactory().create(
    const NewGameRequest(
      saveName: 'Task 31 UI',
      playerTeamId: 'team_europe_0',
      seed: 3101,
    ),
  );
  final base = game.leagueState;
  final playerTeam = base.playerTeam!;
  final otherTeam = base.teams.firstWhere((team) => team.id != playerTeam.id);
  final stableRoster = playerTeam.roster
      .map(
        (player) => player.copyWith(
          contract: player.contract.copyWith(yearsRemaining: 3),
        ),
      )
      .toList();
  final marketPlayer = stableRoster.first.copyWith(
    name: 'Task 31 Roster Player',
    contract: stableRoster.first.contract.copyWith(yearsRemaining: 1),
  );
  final updatedPlayerTeam = playerTeam.copyWith(
    roster: [marketPlayer, ...stableRoster.skip(1)],
    staff: const TeamStaff(),
  );
  const staffCandidate = StaffMember(
    id: 'task31-staff-candidate',
    name: 'Task 31 Scout',
    nationality: Nationality.poland,
    age: 42,
    role: StaffRole.scout,
    attributes: StaffAttributes(coverage: 82, evaluation: 78, negotiation: 65),
  );
  final freeAgent = marketPlayer.copyWith(
    id: 'task31-free-agent',
    name: 'Task 31 Free Agent',
    contract: marketPlayer.contract.copyWith(yearsRemaining: 0),
  );
  final seasonYear = base.currentSeason.year;

  final acceptedTrade = TradeHistoryEntry(
    id: 'task31-trade-accepted',
    teamAId: playerTeam.id,
    teamBId: otherTeam.id,
    seasonYear: seasonYear,
    week: 10,
    day: 1,
    round: 1,
    outcome: 'accepted',
    assetsFromA: [
      TradeAssetSnapshot(type: 'player', playerId: marketPlayer.id),
    ],
    assetsFromB: [
      const TradeAssetSnapshot(type: 'pick', pickYear: 2027, pickRound: 1),
    ],
    reason: 'Wymiana zaakceptowana',
  );
  final rejectedTrade = TradeHistoryEntry(
    id: 'task31-trade-rejected',
    teamAId: playerTeam.id,
    teamBId: otherTeam.id,
    seasonYear: seasonYear,
    week: 20,
    day: 2,
    round: 2,
    outcome: 'rejected',
    assetsFromA: [
      TradeAssetSnapshot(type: 'player', playerId: marketPlayer.id),
    ],
    assetsFromB: [
      const TradeAssetSnapshot(type: 'pick', pickYear: 2027, pickRound: 1),
    ],
    reason: 'Brak zgodności salary cap',
    ntcConsentProbability: 0.42,
  );
  final negotiation = ContractNegotiation(
    id: 'task31-player-negotiation',
    subjectId: freeAgent.id,
    subjectKind: NegotiationSubjectKind.player,
    teamId: playerTeam.id,
    phase: NegotiationPhase.freeAgencyPhaseI,
    round: 2,
    lastOffer: const NegotiationOffer(salary: 1500000, years: 3),
    counterOffer: const NegotiationOffer(salary: 1800000, years: 4),
    status: NegotiationStatus.counter,
    seasonYear: seasonYear,
    week: currentWeek,
    day: currentDay,
    hour: currentHour ?? 0,
    expirySeasonYear: seasonYear,
    expiryWeek: currentWeek,
    expiryDay: 2,
    expiryHour: 2,
    offerScore: 72.5,
  );
  final offerSheet = RfaOfferSheet(
    id: 'task31-rfa-sheet',
    playerId: freeAgent.id,
    originalTeamId: playerTeam.id,
    offeringTeamId: otherTeam.id,
    salary: 2200000,
    years: 3,
    phase: NegotiationPhase.freeAgencyPhaseI,
    seasonYear: seasonYear,
    week: currentWeek,
    day: currentDay,
    hour: currentHour ?? 1,
    expirySeasonYear: seasonYear,
    expiryWeek: currentWeek,
    expiryDay: sheetExpiryDay,
    expiryHour: sheetExpiryHour,
  );

  final league = base.copyWith(
    teams: [
      for (final team in base.teams)
        if (team.id == playerTeam.id) updatedPlayerTeam else team,
    ],
    currentWeek: currentWeek,
    currentDay: currentDay,
    currentHour: currentHour,
    hourlyStaffOfferUsed: hourlyStaffOfferUsed,
    freeAgents: [freeAgent],
    staffFreeAgents: [staffCandidate],
    negotiations: [negotiation],
    tradeHistory: [acceptedTrade, rejectedTrade],
    rfaQualifyingOffers: [
      RfaQualifyingOffer(
        playerId: freeAgent.id,
        ownerTeamId: playerTeam.id,
        salary: 2000000,
        seasonYear: seasonYear,
      ),
    ],
    rfaOfferSheets: [offerSheet],
  );

  return _MarketFixture(
    league: league,
    marketPlayer: freeAgent,
    staffCandidate: staffCandidate,
  );
}

Finder _verticalScrollable() => find.byWidgetPredicate(
  (widget) =>
      widget is Scrollable && widget.axisDirection == AxisDirection.down,
);

Widget _app(Widget screen, LeagueState league) {
  return ProviderScope(
    overrides: [activeLeagueProvider.overrideWithValue(league)],
    child: MaterialApp(
      locale: const Locale('pl'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: screen,
    ),
  );
}
