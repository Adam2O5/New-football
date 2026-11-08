part of 'game_provider.dart';

final balanceProvider = Provider<BalanceConfig>(
  (ref) => BalanceConfig.defaults,
);

final saveRepositoryProvider = Provider((ref) {
  return SaveRepository();
});

final gameFactoryProvider = Provider(
  (ref) => GameFactory(balance: ref.watch(balanceProvider)),
);

final calendarServiceProvider = Provider(
  (ref) => CalendarService(balance: ref.watch(balanceProvider)),
);

final matchContextFactoryProvider = Provider(
  (ref) => MatchContextFactory(
    balance: ref.watch(balanceProvider),
    calendar: ref.watch(calendarServiceProvider),
  ),
);

final matchEngineProvider = Provider(
  (ref) => SimulationMatchEngine(balance: ref.watch(balanceProvider)),
);

final aiMatchdayServiceProvider = Provider(
  (ref) => AiMatchdayService(
    balance: ref.watch(balanceProvider),
    matchEngine: ref.watch(matchEngineProvider),
  ),
);

final aiTradeServiceProvider = Provider(
  (ref) => AiTradeService(
    balance: ref.watch(balanceProvider),
    tradeService: ref.watch(tradeServiceProvider),
  ),
);

final aiRosterManagementServiceProvider = Provider(
  (ref) => AiRosterManagementService(
    balance: ref.watch(balanceProvider),
    contractMarket: ref.watch(contractMarketServiceProvider),
    tradeService: ref.watch(tradeServiceProvider),
    aiTradeService: ref.watch(aiTradeServiceProvider),
  ),
);

final playerEventServiceProvider = Provider(
  (ref) => PlayerEventService(balance: ref.watch(balanceProvider)),
);

final teamEventServiceProvider = Provider(
  (ref) => TeamEventService(balance: ref.watch(balanceProvider)),
);

final daySimulatorProvider = Provider((ref) {
  return DaySimulator(
    balance: ref.watch(balanceProvider),
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
    balance: ref.watch(balanceProvider),
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
    balance: ref.watch(balanceProvider),
    matchEngine: ref.watch(matchEngineProvider),
    aiMatchdayService: ref.watch(aiMatchdayServiceProvider),
    teamEvents: ref.watch(teamEventServiceProvider),
    rosterManagement: ref.watch(aiRosterManagementServiceProvider),
    draftTrade: ref.watch(draftTradeServiceProvider),
  ),
);

final draftServiceProvider = Provider(
  (ref) => DraftService(balance: ref.watch(balanceProvider)),
);

final draftTradeServiceProvider = Provider(
  (ref) => DraftTradeService(
    balance: ref.watch(balanceProvider),
    calendar: ref.watch(calendarServiceProvider),
  ),
);

final staffServiceProvider = Provider(
  (ref) => StaffService(balance: ref.watch(balanceProvider)),
);

final scoutingServiceProvider = Provider(
  (ref) => ScoutingService(balance: ref.watch(balanceProvider)),
);

final contractServiceProvider = Provider(
  (ref) => ContractService(balance: ref.watch(balanceProvider)),
);

final negotiationServiceProvider = Provider(
  (ref) => NegotiationService(balance: ref.watch(balanceProvider)),
);

final tradeServiceProvider = Provider(
  (ref) => TradeService(balance: ref.watch(balanceProvider)),
);

final contractMarketServiceProvider = Provider(
  (ref) => ContractMarketService(
    balance: ref.watch(balanceProvider),
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
