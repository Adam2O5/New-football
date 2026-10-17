part of 'game_provider.dart';

final saveRepositoryProvider = Provider((ref) {
  return SaveRepository();
});

final gameFactoryProvider = Provider((ref) => GameFactory());

final calendarServiceProvider = Provider((ref) => const CalendarService());

final matchContextFactoryProvider = Provider(
  (ref) => MatchContextFactory(calendar: ref.watch(calendarServiceProvider)),
);

final matchEngineProvider = Provider((ref) => SimulationMatchEngine());

final aiMatchdayServiceProvider = Provider(
  (ref) => AiMatchdayService(matchEngine: ref.watch(matchEngineProvider)),
);

final aiTradeServiceProvider = Provider(
  (ref) => AiTradeService(tradeService: ref.watch(tradeServiceProvider)),
);

final aiRosterManagementServiceProvider = Provider(
  (ref) => AiRosterManagementService(
    contractMarket: ref.watch(contractMarketServiceProvider),
    tradeService: ref.watch(tradeServiceProvider),
    aiTradeService: ref.watch(aiTradeServiceProvider),
  ),
);

final playerEventServiceProvider = Provider((ref) => PlayerEventService());

final teamEventServiceProvider = Provider((ref) => TeamEventService());

final daySimulatorProvider = Provider((ref) {
  return DaySimulator(
    matchEngine: ref.watch(matchEngineProvider),
    aiMatchdayService: ref.watch(aiMatchdayServiceProvider),
    aiTradeService: ref.watch(aiTradeServiceProvider),
    rosterManagement: ref.watch(aiRosterManagementServiceProvider),
    playerEvents: ref.watch(playerEventServiceProvider),
    teamEvents: ref.watch(teamEventServiceProvider),
    contractMarket: ref.watch(contractMarketServiceProvider),
    season: ref.watch(seasonServiceProvider),
  );
});

final dayPipelineProvider = Provider(
  (ref) => DayPipeline(
    calendar: ref.watch(calendarServiceProvider),
    days: ref.watch(daySimulatorProvider),
    negotiations: ref.watch(negotiationServiceProvider),
    draftTrades: ref.watch(draftTradeServiceProvider),
    trades: ref.watch(tradeServiceProvider),
    playerEvents: ref.watch(playerEventServiceProvider),
    teamEvents: ref.watch(teamEventServiceProvider),
    contractMarket: ref.watch(contractMarketServiceProvider),
  ),
);

/// Day advancement runs inline by default so tests stay deterministic and
/// free of isolate lifecycles. `main.dart` overrides this with
/// [IsolateSimulationRunner] so the app keeps simulation off the UI isolate.
final simulationRunnerProvider = Provider<SimulationRunner>((ref) {
  final runner = InlineSimulationRunner(ref.watch(dayPipelineProvider));
  ref.onDispose(runner.dispose);
  return runner;
});

final seasonServiceProvider = Provider(
  (ref) => SeasonService(
    matchEngine: ref.watch(matchEngineProvider),
    aiMatchdayService: ref.watch(aiMatchdayServiceProvider),
    teamEvents: ref.watch(teamEventServiceProvider),
    rosterManagement: ref.watch(aiRosterManagementServiceProvider),
    draftTrade: ref.watch(draftTradeServiceProvider),
  ),
);

final draftServiceProvider = Provider((ref) => DraftService());

final draftTradeServiceProvider = Provider(
  (ref) => DraftTradeService(calendar: ref.watch(calendarServiceProvider)),
);

final staffServiceProvider = Provider((ref) => StaffService());

final scoutingServiceProvider = Provider((ref) => ScoutingService());

final contractServiceProvider = Provider((ref) => ContractService());

final negotiationServiceProvider = Provider(
  (ref) => const NegotiationService(),
);

final tradeServiceProvider = Provider((ref) => TradeService());

final contractMarketServiceProvider = Provider(
  (ref) => ContractMarketService(
    calendar: ref.watch(calendarServiceProvider),
    contracts: ref.watch(contractServiceProvider),
    staff: ref.watch(staffServiceProvider),
    negotiations: ref.watch(negotiationServiceProvider),
  ),
);

final savesListProvider = FutureProvider.autoDispose<List<GameSaveMeta>>((
  ref,
) async {
  return ref.watch(saveRepositoryProvider).listSaves();
});
