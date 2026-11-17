/// Generates Mermaid architecture diagrams from the AST of `lib/`.
///
/// Run from the repository root with the Dart SDK shipped with Flutter 3.41.4:
/// `dart run scripts/gen_class_diagrams.dart`
library;

import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';

import 'class_diagram_logic.dart';

final class OverviewPackage {
  const OverviewPackage(this.id, this.directory, this.layer);

  final String id;
  final String directory;
  final int layer;
}

/// Higher layers may import lower layers. Importing a higher layer is
/// [EdgeKind.upLayer]. Screen imports that skip providers are
/// [EdgeKind.bypassProviders]. Entries in [allowedExceptions] stay grey.
const overviewPackages = <OverviewPackage>[
  OverviewPackage('core/models', 'lib/core/models', 0),
  OverviewPackage('core/random', 'lib/core/random', 0),
  OverviewPackage('core/tactics', 'lib/core/tactics', 1),
  OverviewPackage('core/balance', 'lib/core/balance', 1),
  OverviewPackage('core/simulation', 'lib/core/simulation', 2),
  OverviewPackage('core/ai', 'lib/core/ai', 3),
  OverviewPackage('data', 'lib/data', 4),
  OverviewPackage('core/services', 'lib/core/services', 5),
  OverviewPackage('app/providers', 'lib/app/providers', 6),
  OverviewPackage('app/screens', 'lib/app/screens', 7),
];

const allowedExceptions = <AllowedException>[
  AllowedException(
    'data',
    'core/services',
    'adapter w data implementuje interfejs repozytorium zadeklarowany w core/services',
  ),
];

final _packagesById = {
  for (final package in overviewPackages) package.id: package,
};

final class DiagramFile {
  const DiagramFile(this.path, {this.only});

  /// Repo-relative posix path.
  final String path;

  /// When set, only these public type names from [path] are included.
  final Set<String>? only;
}

enum SectionKind { classes, providers, screens }

final class DiagramGroup {
  const DiagramGroup({
    required this.page,
    required this.title,
    required this.description,
    required this.files,
    this.showMembers = true,
    this.includePrivate = false,
    this.section = SectionKind.classes,
  });

  final String page;
  final String title;
  final String description;
  final List<DiagramFile> files;
  final bool showMembers;
  final bool includePrivate;
  final SectionKind section;
}

/// Every class-diagram file group. Insertion order is the document order.
/// Several groups may share one [DiagramGroup.page].
const groups = <String, DiagramGroup>{
  'models.league': DiagramGroup(
    page: 'models.md',
    title: 'Liga, sezon i tabela',
    description:
        'Sezon i jego fazy, tabele konferencji, drabinka play-off, play-in, '
        'siła ligi, loteria draftu oraz koperta zapisu (`GameSave`, '
        '`SaveRecord`). `LeagueState` trzyma też drużyny, skrzynkę i '
        'negocjacje — ich klasy są na kolejnych diagramach.',
    files: [
      DiagramFile('lib/core/models/league_state.dart'),
      DiagramFile('lib/core/models/season.dart'),
      DiagramFile('lib/core/models/season_awards.dart'),
      DiagramFile('lib/core/models/season_history.dart'),
      DiagramFile('lib/core/models/standing.dart'),
      DiagramFile('lib/core/models/league_strength.dart'),
      DiagramFile('lib/core/models/playoff_bracket.dart'),
      DiagramFile('lib/core/models/play_in_models.dart'),
      DiagramFile('lib/core/models/lottery_models.dart'),
      DiagramFile('lib/core/models/lottery_result.dart'),
      DiagramFile('lib/core/models/game_save.dart'),
      DiagramFile('lib/core/models/save_record.dart'),
      DiagramFile(
        'lib/core/models/enums.dart',
        only: {
          'Conference',
          'SeasonPhase',
          'PlayoffRound',
          'TeamStatus',
          'TeamOfSeasonSlot',
        },
      ),
    ],
  ),
  'models.squad': DiagramGroup(
    page: 'models.md',
    title: 'Zawodnik, drużyna i sztab',
    description:
        'Zawodnik, atrybuty z pola i bramkarza, rola, kontuzja, skauting oraz '
        'drużyna ze sztabem, historią tygodnia i statystykami sezonu. Kontrakt, '
        'pick draftu i taktyka są polami `Team` i `Player`, a ich klasy są na '
        'diagramie kontraktów albo w `core/tactics`.',
    files: [
      DiagramFile('lib/core/models/player.dart'),
      DiagramFile('lib/core/models/player_attributes.dart'),
      DiagramFile('lib/core/models/field_player_attributes.dart'),
      DiagramFile('lib/core/models/goalkeeper_attributes.dart'),
      DiagramFile('lib/core/models/assigned_role.dart'),
      DiagramFile('lib/core/models/team.dart'),
      DiagramFile('lib/core/models/staff.dart'),
      DiagramFile('lib/core/models/injury.dart'),
      DiagramFile('lib/core/models/scouting.dart'),
      DiagramFile(
        'lib/core/models/enums.dart',
        only: {'Position', 'StaffRole', 'InjuryType', 'InjuryGroup'},
      ),
    ],
  ),
  'models.market': DiagramGroup(
    page: 'models.md',
    title: 'Kontrakty, wymiany i draft',
    description:
        'Kontrakt zawodnika, wyjątki od capu, finanse klubu, negocjacje, prawa '
        'draftu, RFA, oferty wymiany, stan draftu i prospect.',
    files: [
      DiagramFile('lib/core/models/contract.dart'),
      DiagramFile('lib/core/models/contract_market_models.dart'),
      DiagramFile('lib/core/models/contract_negotiation.dart'),
      DiagramFile('lib/core/models/trade_models.dart'),
      DiagramFile('lib/core/models/draft_class.dart'),
      DiagramFile('lib/core/models/draft_pick.dart'),
      DiagramFile('lib/core/models/draft_state.dart'),
      DiagramFile('lib/core/models/prospect.dart'),
      DiagramFile(
        'lib/core/models/enums.dart',
        only: {'CapExceptionType', 'EstimatedDraftSlot'},
      ),
    ],
  ),
  'models.match': DiagramGroup(
    page: 'models.md',
    title: 'Mecz, wiadomości i zdarzenia',
    description:
        'Zdarzenia i statystyki meczu, konfiguracja spotkania, stan symulacji, '
        'skrzynka wiadomości oraz modyfikatory zawodnika i drużyny.',
    files: [
      DiagramFile('lib/core/models/match_models.dart'),
      DiagramFile('lib/core/models/match_state.dart'),
      DiagramFile('lib/core/models/message.dart'),
      DiagramFile('lib/core/models/player_event_state.dart'),
      DiagramFile('lib/core/models/team_event_state.dart'),
      DiagramFile(
        'lib/core/models/enums.dart',
        only: {
          'MatchEventType',
          'MatchStatus',
          'MatchStake',
          'MessageType',
          'MessageDomain',
          'MessagePriority',
        },
      ),
    ],
  ),
  'services.calendar': DiagramGroup(
    page: 'services.md',
    title: 'Sezon i kalendarz',
    description:
        'Rejestr zdarzeń kalendarza, generator terminarza oraz `SeasonService` '
        'z mixinami faz sezonu, draftu, play-in, play-off i loterii.',
    includePrivate: true,
    files: [
      DiagramFile('lib/core/services/calendar_event_registry.dart'),
      DiagramFile('lib/core/services/calendar_service.dart'),
      DiagramFile('lib/core/services/schedule_generator.dart'),
      DiagramFile('lib/core/services/season_service.dart'),
      DiagramFile('lib/core/services/season_awards.dart'),
      DiagramFile('lib/core/services/season_draft.dart'),
      DiagramFile('lib/core/services/season_fixtures.dart'),
      DiagramFile('lib/core/services/season_lottery.dart'),
      DiagramFile('lib/core/services/season_offseason_events.dart'),
      DiagramFile('lib/core/services/season_play_in.dart'),
      DiagramFile('lib/core/services/season_playoffs.dart'),
      DiagramFile('lib/core/services/season_post_match.dart'),
      DiagramFile('lib/core/services/season_rollover.dart'),
      DiagramFile('lib/core/services/season_scouting.dart'),
      DiagramFile('lib/core/services/lottery_service.dart'),
    ],
  ),
  'services.day': DiagramGroup(
    page: 'services.md',
    title: 'Potok dnia',
    description:
        '`DayPipeline` i `DaySimulator` oraz mixiny wyniku meczu, granicy '
        'tygodnia i aktualizacji świata. Obok jest runner symulacji, także '
        'wariant na izolacie.',
    includePrivate: true,
    files: [
      DiagramFile('lib/core/services/day_pipeline.dart'),
      DiagramFile('lib/core/services/day_simulation_result.dart'),
      DiagramFile('lib/core/services/day_simulator.dart'),
      DiagramFile('lib/core/services/day_match_result_application.dart'),
      DiagramFile('lib/core/services/day_round_resolution.dart'),
      DiagramFile('lib/core/services/day_weekly_boundary.dart'),
      DiagramFile('lib/core/services/day_world_updates.dart'),
      DiagramFile('lib/core/services/simulation_worker.dart'),
    ],
  ),
  'services.market': DiagramGroup(
    page: 'services.md',
    title: 'Rynek kontraktów',
    description:
        '`ContractMarketService` złożony z mixinów ofert, RFA, podpisu i '
        'finalizacji, razem z wyceną oferty, negocjacjami i sztabem.',
    includePrivate: true,
    files: [
      DiagramFile('lib/core/services/contract_market_service.dart'),
      DiagramFile('lib/core/services/contract_market_ai_bridge.dart'),
      DiagramFile('lib/core/services/contract_market_draft_rights.dart'),
      DiagramFile('lib/core/services/contract_market_finalization.dart'),
      DiagramFile('lib/core/services/contract_market_helpers.dart'),
      DiagramFile('lib/core/services/contract_market_player_offers.dart'),
      DiagramFile('lib/core/services/contract_market_resolution.dart'),
      DiagramFile('lib/core/services/contract_market_rfa.dart'),
      DiagramFile('lib/core/services/contract_market_signing.dart'),
      DiagramFile('lib/core/services/contract_market_staff_offers.dart'),
      DiagramFile('lib/core/services/contract_service.dart'),
      DiagramFile('lib/core/services/contract_period_service.dart'),
      DiagramFile('lib/core/services/negotiation_rules.dart'),
      DiagramFile('lib/core/services/negotiation_service.dart'),
      DiagramFile('lib/core/services/staff_service.dart'),
    ],
  ),
  'services.trades': DiagramGroup(
    page: 'services.md',
    title: 'Wymiany i draft',
    description:
        'Oferta wymiany, cap, picki, mock draft i prospect. Walidacja wymiany '
        'i przesunięcie slotu draftu są osobnymi typami wynikowymi.',
    files: [
      DiagramFile('lib/core/services/trade_service.dart'),
      DiagramFile('lib/core/services/draft_service.dart'),
      DiagramFile('lib/core/services/draft_trade_service.dart'),
      DiagramFile('lib/core/services/salary_cap_service.dart'),
      DiagramFile('lib/core/services/mock_draft_service.dart'),
      DiagramFile('lib/core/services/prospect_service.dart'),
    ],
  ),
  'services.events': DiagramGroup(
    page: 'services.md',
    title: 'Zdarzenia i wiadomości',
    description:
        'Zdarzenia zawodnika i drużyny, skrzynka, rozwój, dyscyplina i '
        'kontuzje. Mixiny dzielą decyzje, triggery i treść wiadomości.',
    includePrivate: true,
    files: [
      DiagramFile('lib/core/services/player_event_service.dart'),
      DiagramFile('lib/core/services/player_event_decisions.dart'),
      DiagramFile('lib/core/services/player_event_helpers.dart'),
      DiagramFile('lib/core/services/player_event_messages.dart'),
      DiagramFile('lib/core/services/player_event_triggers.dart'),
      DiagramFile('lib/core/services/team_event_service.dart'),
      DiagramFile('lib/core/services/team_event_decisions.dart'),
      DiagramFile('lib/core/services/team_event_helpers.dart'),
      DiagramFile('lib/core/services/team_event_messages.dart'),
      DiagramFile('lib/core/services/team_event_promises.dart'),
      DiagramFile('lib/core/services/team_event_triggers.dart'),
      DiagramFile('lib/core/services/message_service.dart'),
      DiagramFile('lib/core/services/message_text_service.dart'),
      DiagramFile('lib/core/services/development_service.dart'),
      DiagramFile('lib/core/services/discipline_service.dart'),
      DiagramFile('lib/core/services/injury_service.dart'),
    ],
  ),
  'simulation.engine': DiagramGroup(
    page: 'simulation.md',
    title: 'Silnik meczu',
    description:
        'Wejście do meczu, stan na żywo, walidacja składu, efekty kontekstu '
        'i sam silnik minuty. Emitowane komunikaty meczu są obok.',
    includePrivate: true,
    files: [
      DiagramFile('lib/core/simulation/match_engine.dart'),
      DiagramFile('lib/core/simulation/match_bootstrap.dart'),
      DiagramFile('lib/core/simulation/live_match_state.dart'),
      DiagramFile('lib/core/simulation/matchday_runtime.dart'),
      DiagramFile('lib/core/simulation/pre_match_validator.dart'),
      DiagramFile('lib/core/simulation/match_context_factory.dart'),
      DiagramFile('lib/core/simulation/match_context_effects.dart'),
      DiagramFile('lib/core/simulation/match_message_emitter.dart'),
    ],
  ),
  'simulation.resolvers': DiagramGroup(
    page: 'simulation.md',
    title: 'Rozstrzygnięcia akcji',
    description:
        'Pojedynki, bramkarz, strzał, sekwencja, stały fragment, faul i '
        'składanie statystyk meczu.',
    includePrivate: true,
    files: [
      DiagramFile('lib/core/simulation/duel_resolver.dart'),
      DiagramFile('lib/core/simulation/goalkeeper_resolver.dart'),
      DiagramFile('lib/core/simulation/shot_resolver.dart'),
      DiagramFile('lib/core/simulation/shot_models.dart'),
      DiagramFile('lib/core/simulation/sequence_resolver.dart'),
      DiagramFile('lib/core/simulation/sequence_chain_resolver.dart'),
      DiagramFile('lib/core/simulation/set_piece_resolver.dart'),
      DiagramFile('lib/core/simulation/match_incident_resolver.dart'),
      DiagramFile('lib/core/simulation/match_stats.dart'),
    ],
  ),
  'simulation.tactics': DiagramGroup(
    page: 'simulation.md',
    title: 'Oceny i taktyka',
    description:
        'Atrybuty efektywne, oceny formacji i kształt drużyny razem z '
        '`core/tactics`: ustawienie, sloty składu, role i zmiany.',
    includePrivate: true,
    files: [
      DiagramFile('lib/core/simulation/effective_attributes.dart'),
      DiagramFile('lib/core/simulation/unit_ratings.dart'),
      DiagramFile('lib/core/simulation/team_shape.dart'),
      DiagramFile('lib/core/tactics/tactics_setup.dart'),
      DiagramFile('lib/core/tactics/formation_layout.dart'),
      DiagramFile('lib/core/tactics/lineup_slots.dart'),
      DiagramFile('lib/core/tactics/player_sort.dart'),
      DiagramFile('lib/core/tactics/position_group.dart'),
      DiagramFile('lib/core/tactics/position_role_fit.dart'),
      DiagramFile('lib/core/tactics/substitute_candidates.dart'),
    ],
  ),
  'ai.evaluation': DiagramGroup(
    page: 'ai.md',
    title: 'Ocena składu i aktywów',
    description:
        'Potrzeby pozycji, wartość picka i paczki oraz kontekst, z którego '
        'korzystają decyzje draftu, wymiany i rynku.',
    includePrivate: true,
    files: [
      DiagramFile('lib/core/ai/ai_evaluation_models.dart'),
      DiagramFile('lib/core/ai/ai_evaluation_context.dart'),
      DiagramFile('lib/core/ai/ai_evaluation_service.dart'),
    ],
  ),
  'ai.decisions': DiagramGroup(
    page: 'ai.md',
    title: 'Decyzje AI',
    description:
        'Meczowy plan AI, draft, wymiana, rynek kontraktów i prowadzenie '
        'składu. `TeamAiService` spina te serwisy.',
    includePrivate: true,
    files: [
      DiagramFile('lib/core/ai/ai_matchday_models.dart'),
      DiagramFile('lib/core/ai/ai_matchday_service.dart'),
      DiagramFile('lib/core/ai/ai_draft_models.dart'),
      DiagramFile('lib/core/ai/ai_draft_service.dart'),
      DiagramFile('lib/core/ai/ai_trade_models.dart'),
      DiagramFile('lib/core/ai/ai_trade_service.dart'),
      DiagramFile('lib/core/ai/ai_contract_market_service.dart'),
      DiagramFile('lib/core/ai/ai_roster_management_service.dart'),
      DiagramFile('lib/core/ai/team_ai_service.dart'),
    ],
  ),
  'balance.config': DiagramGroup(
    page: 'balance.md',
    title: 'Konfiguracja balansu',
    description:
        '`BalanceConfig` i klasy parametrów. Pola liczbowe są pominięte. '
        'Katalogi szablonów wiadomości i rywalizacji zostają poza diagramem, '
        'bo to tabele treści, a nie kształt konfiguracji.',
    showMembers: false,
    files: [
      DiagramFile('lib/core/balance/balance_config.dart'),
      DiagramFile('lib/core/balance/ai_balance.dart'),
      DiagramFile('lib/core/balance/contract_neg_balance.dart'),
      DiagramFile('lib/core/balance/development_balance.dart'),
      DiagramFile('lib/core/balance/draft_awards_balance.dart'),
      DiagramFile('lib/core/balance/events_balance.dart'),
      DiagramFile('lib/core/balance/finance_balance.dart'),
      DiagramFile('lib/core/balance/injury_catalog.dart'),
      DiagramFile('lib/core/balance/matchday_balance.dart'),
      DiagramFile('lib/core/balance/messages_balance.dart'),
      DiagramFile('lib/core/balance/player_balance.dart'),
      DiagramFile('lib/core/balance/scouting_balance.dart'),
      DiagramFile('lib/core/balance/seed_balance.dart'),
      DiagramFile('lib/core/balance/simulation_profiles_balance.dart'),
      DiagramFile('lib/core/balance/staff_balance.dart'),
      DiagramFile('lib/core/balance/tactics_balance.dart'),
      DiagramFile('lib/core/balance/team_calendar_balance.dart'),
      DiagramFile('lib/core/balance/trade_value_balance.dart'),
      DiagramFile('lib/core/balance/ui_balance.dart'),
    ],
  ),
  'persistence.saves': DiagramGroup(
    page: 'persistence.md',
    title: 'Zapis i losowość',
    description:
        'Repozytorium zapisu, jego transakcja i odczyt, adapter interfejsu '
        'z `core/services` oraz generatory liczb z `core/random`.',
    includePrivate: true,
    files: [
      DiagramFile('lib/data/save_repository.dart'),
      DiagramFile('lib/data/save_repository_raw_operations.dart'),
      DiagramFile('lib/data/save_repository_transaction.dart'),
      DiagramFile('lib/data/save_repository_types.dart'),
      DiagramFile('lib/data/save_recovery.dart'),
      DiagramFile('lib/data/save_directory_coordinator.dart'),
      DiagramFile('lib/data/save_management_repository_adapter.dart'),
      DiagramFile('lib/data/staff_data_compatibility.dart'),
      DiagramFile('lib/core/services/save_management_repository.dart'),
      DiagramFile('lib/core/random/match_random.dart'),
      DiagramFile('lib/core/random/seeds.dart'),
    ],
  ),
  'app.providers': DiagramGroup(
    page: 'app.md',
    title: 'Providery i serwisy',
    description:
        'Węzeł to `nazwa: typ` widoczny dla `ref.watch`. Ciągła krawędź to '
        '`ref.watch`, przerywana to `ref.read`. `.notifier`, `.future` i '
        '`.select(...)` liczą się jako ten sam provider. Graf serwisów jest '
        'osobno od kontrolera i ustawień.',
    section: SectionKind.providers,
    files: [
      DiagramFile('lib/app/providers/game_provider.dart'),
      DiagramFile('lib/app/providers/game_service_providers.dart'),
      DiagramFile('lib/app/providers/game_simulation_types.dart'),
      DiagramFile('lib/app/providers/game_controller_calendar_feedback.dart'),
      DiagramFile('lib/app/providers/game_controller_contracts.dart'),
      DiagramFile('lib/app/providers/game_controller_draft_scouting.dart'),
      DiagramFile('lib/app/providers/game_controller_messages.dart'),
      DiagramFile('lib/app/providers/game_controller_simulation.dart'),
      DiagramFile('lib/app/providers/development_provider.dart'),
      DiagramFile('lib/app/providers/message_confirmation.dart'),
      DiagramFile('lib/app/providers/save_management_provider.dart'),
      DiagramFile('lib/app/providers/search_filters_provider.dart'),
      DiagramFile('lib/app/providers/settings_provider.dart'),
      DiagramFile('lib/app/providers/club_branding_provider.dart'),
    ],
  ),
  'app.screens': DiagramGroup(
    page: 'app.md',
    title: 'Ekrany i providery',
    description:
        'Dla każdego `*_screen.dart` nazwy providerów użyte przez `ref.watch` '
        'i `ref.read`. Widżety i pliki pomocnicze obok ekranu nie wchodzą '
        'na listę.',
    section: SectionKind.screens,
    files: [DiagramFile('lib/app/screens')],
  ),
};

final class PageInfo {
  const PageInfo({required this.title, required this.intro, this.omittedUnder});

  final String title;
  final String intro;

  /// When set, the page lists hand-written Dart files under this directory
  /// that no group includes.
  final String? omittedUnder;
}

const pages = <String, PageInfo>{
  'models.md': PageInfo(
    title: 'Modele domenowe',
    intro:
        'Cztery wycinki `lib/core/models`. Każdy diagram ma własny opis i '
        'trzyma się granicy około 40 typów.\n\n'
        '`enums.dart` jest dzielony między diagramy polem `only`, bo jeden '
        'plik miesza wszystkie domeny. Formacje i role taktyczne zostają poza '
        'tymi diagramami.\n\n'
        'Poza diagramami zostają pliki bez typu w tych wycinkach albo '
        'generatory i stan UI:',
    omittedUnder: 'lib/core/models',
  ),
  'services.md': PageInfo(
    title: 'Serwisy',
    intro:
        'Pięć wycinków `lib/core/services`. Mixiny prywatne są na diagramie, '
        'bo to one dzielą sezon, dzień, rynek i zdarzenia.',
    omittedUnder: 'lib/core/services',
  ),
  'simulation.md': PageInfo(
    title: 'Symulacja i taktyka',
    intro:
        '`lib/core/simulation` razem z `lib/core/tactics`. Silnik, '
        'rozstrzygnięcia akcji oraz oceny z ustawieniem taktycznym.',
    omittedUnder: 'lib/core/simulation',
  ),
  'ai.md': PageInfo(
    title: 'Sztuczna inteligencja',
    intro:
        'Ocena składu jest osobno od decyzji meczowych, draftu, wymiany i '
        'rynku, żeby żaden diagram nie przekroczył około 40 typów.',
    omittedUnder: 'lib/core/ai',
  ),
  'balance.md': PageInfo(
    title: 'Balans',
    intro:
        'Klasy konfiguracji bez pól liczbowych. Relacja pokazuje, co '
        '`BalanceConfig` trzyma.',
    omittedUnder: 'lib/core/balance',
  ),
  'persistence.md': PageInfo(
    title: 'Trwałość',
    intro:
        '`lib/data` oraz `lib/core/random`. Interfejs repozytorium zostaje '
        'w `core/services`, a adapter w `data` go implementuje.',
    omittedUnder: 'lib/data',
  ),
  'app.md': PageInfo(
    title: 'Aplikacja',
    intro:
        'Providery połączone przez `ref.watch` i `ref.read` oraz lista '
        'ekranów. Widżety nie są na tej stronie.',
  ),
};

const _skippedMembers = <String>{
  'copyWith',
  'toJson',
  'fromJson',
  'hashCode',
  'toString',
};

const _collectionTypes = <String>{'List', 'Set', 'Iterable', 'Map'};

const _maxTypesPerDiagram = 40;

const _generatedBanner =
    '<!-- Generated by scripts/gen_class_diagrams.dart. Do not edit by hand. -->';

void main() {
  final root = findRepoRoot();
  final library = _Library(root);
  final importGraph = _scanImports(root, library);
  final diagrams = [
    for (final entry in groups.entries)
      ...switch (entry.value.section) {
        SectionKind.classes => [_renderGroup(library, entry.key, entry.value)],
        SectionKind.providers => _renderProviderDiagrams(
          library,
          entry.key,
          entry.value,
        ),
        SectionKind.screens => [
          _renderScreenProviders(library, entry.key, entry.value),
        ],
      },
  ];
  final outDir = Directory('${root.path}/docs/architecture');
  outDir.createSync(recursive: true);

  File(
    '${outDir.path}/README.md',
  ).writeAsStringSync(renderReadme(importGraph, diagrams));

  final byPage = <String, List<RenderedDiagram>>{};
  for (final diagram in diagrams) {
    byPage.putIfAbsent(diagram.page, () => []).add(diagram);
  }
  for (final entry in byPage.entries) {
    File(
      '${outDir.path}/${entry.key}',
    ).writeAsStringSync(renderPage(root, entry.key, entry.value));
  }

  stdout.writeln('Wrote docs/architecture/README.md');
  for (final page in byPage.keys) {
    stdout.writeln('Wrote docs/architecture/$page');
  }
  for (final diagram in diagrams) {
    stdout.writeln(
      '${diagram.id}: ${diagram.typeCount} types, ${diagram.mermaid.length} chars',
    );
  }
  final marked = importGraph.edges.where(
    (edge) => edge.kind != EdgeKind.normal,
  );
  stdout.writeln(
    'Imports: ${importGraph.edges.length} edges, '
    '${marked.length} marked, '
    'cycles: ${importGraph.cycles.map((cycle) => cycle.join('+')).join(' | ')}',
  );
  for (final edge in marked) {
    stdout.writeln(
      '${edge.kind.name} ${edge.from} -> ${edge.to} = ${edge.count}',
    );
  }
}

Directory findRepoRoot() {
  var dir = Directory.current.absolute;
  while (true) {
    final pubspec = File('${dir.path}/pubspec.yaml');
    final script = File('${dir.path}/scripts/gen_class_diagrams.dart');
    if (pubspec.existsSync() && script.existsSync()) return dir;
    final parent = dir.parent;
    if (parent.path == dir.path) {
      throw StateError('Run this script from the New Football repository.');
    }
    dir = parent;
  }
}

bool isGeneratedPath(String relative) {
  if (!relative.startsWith('lib/') || !relative.endsWith('.dart')) return true;
  if (relative.endsWith('.g.dart') || relative.endsWith('.freezed.dart')) {
    return true;
  }
  if (relative == 'lib/l10n/generated' ||
      relative.startsWith('lib/l10n/generated/')) {
    return true;
  }
  return false;
}

String? packageOf(String relative) {
  final path = relative.startsWith('lib/') ? relative.substring(4) : relative;
  for (final package in overviewPackages) {
    final directory = package.directory.substring('lib/'.length);
    if (path == directory || path.startsWith('$directory/')) return package.id;
  }
  return null;
}

int layerOf(String id) =>
    _packagesById[id]?.layer ?? (throw StateError('Unknown package $id'));

int packageIndex(String id) {
  for (var i = 0; i < overviewPackages.length; i++) {
    if (overviewPackages[i].id == id) return i;
  }
  return overviewPackages.length;
}

String nodeId(String packageId) => 'pkg_${packageId.replaceAll('/', '_')}';

final class ImportEdge {
  const ImportEdge({
    required this.from,
    required this.to,
    required this.count,
    required this.sample,
    required this.kind,
    this.note = '',
  });

  final String from;
  final String to;
  final int count;
  final String sample;
  final EdgeKind kind;
  final String note;
}

final class ImportGraph {
  const ImportGraph(this.edges, this.cycles);

  final List<ImportEdge> edges;
  final List<List<String>> cycles;
}

final class _ImportAccum {
  int count = 0;
  String? sample;
}

ImportGraph _scanImports(Directory root, _Library library) {
  final counts = <(String, String), _ImportAccum>{};
  final files =
      Directory('${root.path}/lib')
          .listSync(recursive: true)
          .whereType<File>()
          .map((file) => relativePosix(root.path, file.path))
          .where((path) => !isGeneratedPath(path))
          .toList()
        ..sort();

  for (final relative in files) {
    final fromPackage = packageOf(relative);
    if (fromPackage == null) continue;
    final unit = library.unit(relative);
    for (final directive in unit.directives) {
      if (directive is! ImportDirective) continue;
      final uri = directive.uri.stringValue;
      if (uri == null) continue;
      final target = resolveImport(relative, uri);
      if (target == null) continue;
      final toPackage = packageOf(target);
      if (toPackage == null || toPackage == fromPackage) continue;
      final sample = '$relative -> $uri';
      final accum = counts.putIfAbsent((
        fromPackage,
        toPackage,
      ), _ImportAccum.new);
      accum.count += 1;
      if (accum.sample == null || sample.compareTo(accum.sample!) < 0) {
        accum.sample = sample;
      }
    }
  }

  final graph = <String, Set<String>>{
    for (final package in overviewPackages) package.id: <String>{},
  };
  for (final entry in counts.entries) {
    graph[entry.key.$1]!.add(entry.key.$2);
  }
  final components = stronglyConnected(graph.keys.toSet(), graph);
  final cycles = [
    for (final component in components)
      if (component.length > 1) (component.toList()..sort()),
  ]..sort((a, b) => a.join().compareTo(b.join()));

  final keys = counts.keys.toList()
    ..sort((a, b) {
      final byFrom = packageIndex(a.$1).compareTo(packageIndex(b.$1));
      if (byFrom != 0) return byFrom;
      return packageIndex(a.$2).compareTo(packageIndex(b.$2));
    });

  final edges = [for (final key in keys) _classifiedEdge(key, counts[key]!)];
  return ImportGraph(edges, cycles);
}

ImportEdge _classifiedEdge((String, String) key, _ImportAccum accum) {
  final exception = allowedExceptions
      .where((item) => item.from == key.$1 && item.to == key.$2)
      .firstOrNull;
  final kind = classifyEdge(
    from: key.$1,
    to: key.$2,
    fromLayer: layerOf(key.$1),
    toLayer: layerOf(key.$2),
    isAllowedException: exception != null,
  );
  return ImportEdge(
    from: key.$1,
    to: key.$2,
    count: accum.count,
    sample: accum.sample ?? '',
    kind: kind,
    note: exception?.note ?? '',
  );
}

String relativePosix(String root, String absolute) {
  final prefix = root.endsWith('/') ? root : '$root/';
  final relative = absolute.startsWith(prefix)
      ? absolute.substring(prefix.length)
      : absolute;
  return relative.replaceAll('\\', '/');
}

final class _Library {
  _Library(this.root);

  final Directory root;
  final _units = <String, CompilationUnit>{};

  CompilationUnit unit(String relative) {
    return _units.putIfAbsent(relative, () {
      return parseString(
        content: File('${root.path}/$relative').readAsStringSync(),
        path: relative,
      ).unit;
    });
  }
}

enum _TypeKind { classKind, mixinKind, enumKind, extensionKind }

enum _RelKind { extendsRel, implementsRel, composition, dependency }

final class _Field {
  _Field({required this.name, required this.type, required this.isStatic});

  final String name;
  String type;
  final bool isStatic;
  bool compositional = false;
  TypeAnnotation? sourceType;
}

final class _Member {
  const _Member(this.name, this.rendered);

  final String name;
  final String rendered;
}

final class _Relation {
  const _Relation({
    required this.kind,
    required this.source,
    required this.target,
    required this.label,
    required this.many,
    required this.nullable,
  });

  final _RelKind kind;
  final String source;
  final String target;
  final String label;
  final bool many;
  final bool nullable;
}

final class _TypeModel {
  _TypeModel({
    required this.simpleName,
    required this.id,
    required this.kind,
    required this.compositional,
  });

  final String simpleName;
  final String id;
  final _TypeKind kind;
  final bool compositional;
  bool freezed = false;
  final List<String> stereotypes = [];
  final List<String> enumConstants = [];
  final Map<String, _Field> fields = {};
  final Map<String, _Member> methods = {};
  final List<ConstructorDeclaration> constructors = [];
  NamedType? superclass;
  final List<NamedType> mixins = [];
  final List<NamedType> interfaces = [];
  final List<NamedType> constraints = [];
  TypeAnnotation? extendedType;
}

final class RenderedDiagram {
  const RenderedDiagram({
    required this.id,
    required this.page,
    required this.title,
    required this.description,
    required this.files,
    required this.typeCount,
    required this.mermaid,
    this.fenced = true,
    this.countLine,
  });

  final String id;
  final String page;
  final String title;
  final String description;
  final List<String> files;
  final int typeCount;
  final String mermaid;
  final bool fenced;
  final String? countLine;
}

RenderedDiagram _renderGroup(_Library library, String id, DiagramGroup group) {
  final types = <_TypeModel>[];
  final seenNames = <String, String>{};
  for (final file in group.files) {
    final source = File('${library.root.path}/${file.path}');
    if (!source.existsSync()) {
      throw StateError('Missing diagram file ${file.path}');
    }
    final unit = library.unit(file.path);
    final found = <String>{};
    for (final declaration in unit.declarations) {
      final model = _readDeclaration(declaration);
      if (model == null) continue;
      if (!group.includePrivate && model.simpleName.startsWith('_')) continue;
      found.add(model.simpleName);
      if (file.only != null && !file.only!.contains(model.simpleName)) {
        continue;
      }
      final previous = seenNames[model.simpleName];
      if (previous != null) {
        throw StateError(
          'Duplicate type ${model.simpleName} in $id '
          '($previous and ${file.path})',
        );
      }
      seenNames[model.simpleName] = file.path;
      types.add(model);
    }
    if (file.only != null) {
      final missing = file.only!.difference(found).toList()..sort();
      if (missing.isNotEmpty) {
        throw StateError(
          '${file.path} is missing ${missing.join(', ')} for $id',
        );
      }
    }
  }

  if (types.length > _maxTypesPerDiagram) {
    final names = types.map((type) => type.simpleName).toList()..sort();
    throw StateError(
      '$id has ${types.length} types (limit $_maxTypesPerDiagram): '
      '${names.join(', ')}',
    );
  }

  final byName = {for (final type in types) type.simpleName: type.id};
  final relations = <_Relation>[
    for (final type in types) ..._relationsFor(type, byName),
  ];
  types.sort((a, b) => a.id.compareTo(b.id));
  final mermaid = _renderClassDiagram(
    types,
    relations,
    showMembers: group.showMembers,
  );
  _assertMermaidSafe(id, mermaid);
  return RenderedDiagram(
    id: id,
    page: group.page,
    title: group.title,
    description: _describe(group),
    files: [for (final file in group.files) file.path],
    typeCount: types.length,
    mermaid: mermaid,
  );
}

void _assertMermaidSafe(String id, String mermaid) {
  final problem = mermaidProblem(mermaid);
  if (problem != null) throw StateError('$id: $problem');
}

String _describe(DiagramGroup group) {
  final picked = <String>[
    for (final file in group.files)
      if (file.only != null) ...file.only!,
  ]..sort();
  if (picked.isEmpty) return group.description;
  final names = picked.map((name) => '`$name`').join(', ');
  return '${group.description} Z `enums.dart`: $names.';
}

_TypeModel? _readDeclaration(CompilationUnitMember declaration) {
  if (declaration is ClassDeclaration) return _readClass(declaration);
  if (declaration is MixinDeclaration) return _readMixin(declaration);
  if (declaration is EnumDeclaration) return _readEnum(declaration);
  if (declaration is ExtensionDeclaration) return _readExtension(declaration);
  if (declaration is ExtensionTypeDeclaration) {
    return _readExtensionType(declaration);
  }
  return null;
}

_TypeModel _readClass(ClassDeclaration declaration) {
  final name = declaration.namePart.typeName.lexeme;
  final model = _TypeModel(
    simpleName: name,
    id: _typeId(name, declaration.namePart.typeParameters),
    kind: _TypeKind.classKind,
    compositional: true,
  );
  model.freezed = _isFreezed(declaration, declaration.withClause);
  if (declaration.mixinKeyword != null) model.stereotypes.add('mixin');
  if (model.freezed) model.stereotypes.add('freezed');
  model.superclass = declaration.extendsClause?.superclass;
  model.mixins.addAll(declaration.withClause?.mixinTypes ?? const []);
  model.interfaces.addAll(declaration.implementsClause?.interfaces ?? const []);
  _collectMembers(model, _bodyMembers(declaration.body));
  return model;
}

_TypeModel _readMixin(MixinDeclaration declaration) {
  final name = declaration.name.lexeme;
  final model = _TypeModel(
    simpleName: name,
    id: _typeId(name, declaration.typeParameters),
    kind: _TypeKind.mixinKind,
    compositional: true,
  );
  model.stereotypes.add('mixin');
  model.freezed = _isFreezed(declaration, null);
  if (model.freezed) model.stereotypes.add('freezed');
  model.constraints.addAll(
    declaration.onClause?.superclassConstraints ?? const [],
  );
  model.interfaces.addAll(declaration.implementsClause?.interfaces ?? const []);
  _collectMembers(model, declaration.body.members);
  return model;
}

_TypeModel _readEnum(EnumDeclaration declaration) {
  final name = declaration.namePart.typeName.lexeme;
  final model = _TypeModel(
    simpleName: name,
    id: _typeId(name, declaration.namePart.typeParameters),
    kind: _TypeKind.enumKind,
    compositional: true,
  );
  model.stereotypes.add('enumeration');
  model.freezed = _isFreezed(declaration, declaration.withClause);
  if (model.freezed) model.stereotypes.add('freezed');
  model.mixins.addAll(declaration.withClause?.mixinTypes ?? const []);
  model.interfaces.addAll(declaration.implementsClause?.interfaces ?? const []);
  for (final constant in declaration.body.constants) {
    final constantName = constant.name.lexeme;
    if (!constantName.startsWith('_')) model.enumConstants.add(constantName);
  }
  model.enumConstants.sort();
  _collectMembers(model, declaration.body.members);
  return model;
}

_TypeModel _readExtension(ExtensionDeclaration declaration) {
  final onType = declaration.onClause?.extendedType;
  final name = declaration.name?.lexeme ?? _anonymousExtensionName(onType);
  final model = _TypeModel(
    simpleName: name,
    id: _typeId(name, declaration.typeParameters),
    kind: _TypeKind.extensionKind,
    compositional: false,
  );
  model.stereotypes.add('extension');
  model.extendedType = onType;
  _collectMembers(model, declaration.body.members);
  return model;
}

_TypeModel _readExtensionType(ExtensionTypeDeclaration declaration) {
  final name = declaration.primaryConstructor.typeName.lexeme;
  final model = _TypeModel(
    simpleName: name,
    id: _typeId(name, declaration.primaryConstructor.typeParameters),
    kind: _TypeKind.classKind,
    compositional: true,
  );
  model.stereotypes.add('extensionType');
  model.interfaces.addAll(declaration.implementsClause?.interfaces ?? const []);
  for (final parameter
      in declaration.primaryConstructor.formalParameters.parameters) {
    _addParameterField(model, parameter);
  }
  _collectMembers(model, _bodyMembers(declaration.body));
  return model;
}

String _anonymousExtensionName(TypeAnnotation? onType) {
  if (onType is NamedType) return 'ExtensionOn${onType.name.lexeme}';
  return 'AnonymousExtension';
}

String _typeId(String name, TypeParameterList? parameters) {
  const reserved = {'end', 'class', 'style', 'direction', 'click', 'callback'};
  var safe = name.replaceAll(RegExp(r'[^A-Za-z0-9_]'), '_');
  if (reserved.contains(safe)) safe = '${safe}Type';
  if (parameters == null || parameters.typeParameters.isEmpty) return safe;
  final args = parameters.typeParameters
      .map((parameter) => parameter.name.lexeme)
      .join(', ');
  return '$safe~$args~';
}

bool _isFreezed(AnnotatedNode node, WithClause? withClause) {
  for (final annotation in node.metadata) {
    final name = annotation.name;
    final short = name is PrefixedIdentifier ? name.identifier.name : name.name;
    if (short == 'freezed' || short == 'Freezed') return true;
  }
  if (withClause == null) return false;
  return withClause.mixinTypes.any(
    (type) => type.name.lexeme.startsWith(r'_$'),
  );
}

List<ClassMember> _bodyMembers(ClassBody body) {
  if (body is BlockClassBody) return body.members;
  return const [];
}

void _collectMembers(_TypeModel model, List<ClassMember> members) {
  for (final member in members) {
    if (member is FieldDeclaration) {
      final annotation = member.fields.type;
      final rendered = annotation == null ? '' : _renderType(annotation);
      for (final variable in member.fields.variables) {
        _addField(
          model,
          variable.name.lexeme,
          rendered,
          isStatic: member.isStatic,
          compositional: model.compositional && !member.isStatic,
          sourceType: annotation,
        );
      }
    } else if (member is MethodDeclaration) {
      _addMethod(model, member);
    } else if (member is ConstructorDeclaration) {
      model.constructors.add(member);
    }
  }
  if (model.freezed) {
    for (final constructor in model.constructors) {
      if (constructor.factoryKeyword == null || constructor.name != null) {
        continue;
      }
      for (final parameter in constructor.parameters.parameters) {
        _addParameterField(model, parameter);
      }
    }
  }
  _fillFieldFormalTypes(model);
}

void _fillFieldFormalTypes(_TypeModel model) {
  for (final constructor in model.constructors) {
    for (final parameter in constructor.parameters.parameters) {
      final inner = _unwrapParameter(parameter);
      if (inner is! FieldFormalParameter || inner.type == null) continue;
      final field = model.fields[inner.name.lexeme];
      if (field != null && field.type.isEmpty) {
        field.type = _renderType(inner.type!);
        field.sourceType ??= inner.type;
      }
    }
  }
}

void _addParameterField(_TypeModel model, FormalParameter parameter) {
  final inner = _unwrapParameter(parameter);
  final name = inner.name?.lexeme;
  if (name == null || name.startsWith('_')) return;
  final annotation = _parameterType(inner);
  _addField(
    model,
    name,
    annotation == null ? '' : _renderType(annotation),
    isStatic: false,
    compositional: true,
    sourceType: annotation,
  );
}

void _addField(
  _TypeModel model,
  String name,
  String type, {
  required bool isStatic,
  required bool compositional,
  required TypeAnnotation? sourceType,
}) {
  if (name.startsWith('_') || _skippedMembers.contains(name)) return;
  final existing = model.fields[name];
  if (existing != null) {
    if (existing.type.isEmpty && type.isNotEmpty) {
      existing.type = type;
      existing.sourceType ??= sourceType;
    }
    return;
  }
  model.fields[name] = _Field(name: name, type: type, isStatic: isStatic)
    ..compositional = compositional
    ..sourceType = sourceType;
}

void _addMethod(_TypeModel model, MethodDeclaration method) {
  final name = method.name.lexeme;
  if (name.startsWith('_') || _skippedMembers.contains(name)) return;
  if (method.isOperator || method.isSetter) return;
  if (method.isGetter) {
    _addField(
      model,
      name,
      method.returnType == null ? '' : _renderType(method.returnType!),
      isStatic: method.isStatic,
      compositional: false,
      sourceType: null,
    );
    return;
  }
  if (model.methods.containsKey(name)) return;
  final parameters = method.parameters;
  final renderedParameters = parameters == null
      ? ''
      : _renderParameters(parameters.parameters);
  final returnType = method.returnType == null
      ? ''
      : _renderType(method.returnType!);
  final buffer = StringBuffer('+$name($renderedParameters)');
  if (returnType.isNotEmpty) buffer.write(' $returnType');
  if (method.isStatic) buffer.write(r'$');
  model.methods[name] = _Member(name, sanitizeMember(buffer.toString()));
}

String _renderParameters(List<FormalParameter> parameters) {
  final parts = <String>[];
  for (final parameter in parameters) {
    final inner = _unwrapParameter(parameter);
    final name = inner.name?.lexeme ?? '';
    if (name.startsWith('_')) continue;
    final annotation = _parameterType(inner);
    final type = annotation == null ? '' : _renderType(annotation);
    final piece = [
      if (type.isNotEmpty) type,
      if (name.isNotEmpty) name,
    ].join(' ');
    if (piece.isNotEmpty) parts.add(sanitizeMember(piece));
  }
  return limitParameterList(parts);
}

FormalParameter _unwrapParameter(FormalParameter parameter) {
  if (parameter is DefaultFormalParameter) return parameter.parameter;
  return parameter;
}

TypeAnnotation? _parameterType(FormalParameter parameter) {
  if (parameter is SimpleFormalParameter) return parameter.type;
  if (parameter is FieldFormalParameter) return parameter.type;
  if (parameter is SuperFormalParameter) return parameter.type;
  return null;
}

String _renderType(TypeAnnotation type) {
  if (type is NamedType) {
    final arguments = type.typeArguments?.arguments;
    final nullable = type.question == null ? '' : '?';
    if (arguments == null || arguments.isEmpty) {
      return '${type.name.lexeme}$nullable';
    }
    final inner = arguments.map(_renderType).join(', ');
    return '${type.name.lexeme}~$inner~$nullable';
  }
  if (type is GenericFunctionType) return 'Function';
  if (type is RecordTypeAnnotation) return 'Record';
  return 'Type';
}

List<String> _linkedTypeNames(TypeAnnotation type) {
  if (type is NamedType) {
    final name = type.name.lexeme;
    final arguments = type.typeArguments?.arguments;
    if (_collectionTypes.contains(name)) {
      if (arguments == null) return const [];
      return [for (final argument in arguments) ..._linkedTypeNames(argument)];
    }
    return [name];
  }
  if (type is RecordTypeAnnotation) {
    final names = <String>[];
    for (final field in type.positionalFields) {
      names.addAll(_linkedTypeNames(field.type));
    }
    final named = type.namedFields;
    if (named != null) {
      for (final field in named.fields) {
        names.addAll(_linkedTypeNames(field.type));
      }
    }
    return names;
  }
  return const [];
}

List<_Relation> _relationsFor(_TypeModel type, Map<String, String> byName) {
  final relations = <_Relation>[];
  final composed = <String>{};

  void addRelation({
    required _RelKind kind,
    required String? targetName,
    required String label,
    bool many = false,
    bool nullable = false,
  }) {
    if (targetName == null) return;
    final target = byName[targetName];
    if (target == null) return;
    relations.add(
      _Relation(
        kind: kind,
        source: type.id,
        target: target,
        label: _safeLabel(label),
        many: many,
        nullable: nullable,
      ),
    );
    if (kind == _RelKind.composition) composed.add(target);
  }

  for (final field in type.fields.values) {
    final sourceType = field.sourceType;
    if (!field.compositional || sourceType == null) continue;
    final shape = _collectionShape(sourceType);
    for (final targetName in _linkedTypeNames(sourceType)) {
      addRelation(
        kind: _RelKind.composition,
        targetName: targetName,
        label: field.name,
        many: shape.many,
        nullable: shape.nullable && !shape.many,
      );
    }
  }

  for (final constructor in type.constructors) {
    final constructorName = constructor.name?.lexeme;
    if (constructorName != null &&
        (constructorName.startsWith('_') ||
            _skippedMembers.contains(constructorName))) {
      continue;
    }
    final primaryFreezed =
        type.freezed &&
        constructor.factoryKeyword != null &&
        constructor.name == null;
    if (primaryFreezed) continue;
    for (final parameter in constructor.parameters.parameters) {
      final inner = _unwrapParameter(parameter);
      if (inner is FieldFormalParameter) continue;
      final annotation = _parameterType(inner);
      if (annotation == null) continue;
      final label = inner.name?.lexeme ?? 'ctor';
      for (final targetName in _linkedTypeNames(annotation)) {
        final target = byName[targetName];
        if (target == null || composed.contains(target)) continue;
        addRelation(
          kind: _RelKind.dependency,
          targetName: targetName,
          label: label,
        );
      }
    }
  }

  if (type.superclass != null) {
    addRelation(
      kind: _RelKind.extendsRel,
      targetName: type.superclass!.name.lexeme,
      label: '',
    );
  }
  for (final mixinType in type.mixins) {
    addRelation(
      kind: _RelKind.implementsRel,
      targetName: mixinType.name.lexeme,
      label: 'with',
    );
  }
  for (final interfaceType in type.interfaces) {
    addRelation(
      kind: _RelKind.implementsRel,
      targetName: interfaceType.name.lexeme,
      label: 'implements',
    );
  }
  for (final constraint in type.constraints) {
    addRelation(
      kind: _RelKind.implementsRel,
      targetName: constraint.name.lexeme,
      label: 'on',
    );
  }
  final extended = type.extendedType;
  if (extended != null) {
    for (final targetName in _linkedTypeNames(extended)) {
      addRelation(
        kind: _RelKind.dependency,
        targetName: targetName,
        label: 'on',
      );
    }
  }
  return relations;
}

final class _Shape {
  const _Shape({required this.many, required this.nullable});

  final bool many;
  final bool nullable;
}

_Shape _collectionShape(TypeAnnotation annotation) {
  if (annotation is! NamedType) {
    return const _Shape(many: false, nullable: false);
  }
  return _Shape(
    many: _collectionTypes.contains(annotation.name.lexeme),
    nullable: annotation.question != null,
  );
}

String _safeLabel(String label) {
  if (RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$').hasMatch(label)) return label;
  return '';
}

String _renderClassDiagram(
  List<_TypeModel> types,
  List<_Relation> relations, {
  required bool showMembers,
}) {
  final buffer = StringBuffer('classDiagram\n');
  for (final type in types) {
    buffer.writeln('    class ${type.id} {');
    for (final stereotype in type.stereotypes) {
      buffer.writeln('        <<$stereotype>>');
    }
    if (showMembers) {
      for (final constant in type.enumConstants) {
        buffer.writeln('        ${sanitizeMember(constant)}');
      }
      final fields = type.fields.values.toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      for (final field in fields) {
        final typeText = field.type.isEmpty ? '' : '${field.type} ';
        final staticMark = field.isStatic ? r'$' : '';
        buffer.writeln(
          '        ${sanitizeMember('+$typeText${field.name}$staticMark')}',
        );
      }
      final methods = type.methods.values.toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      for (final method in methods) {
        buffer.writeln('        ${method.rendered}');
      }
    }
    buffer.writeln('    }');
  }

  final unique = <String, _Relation>{};
  for (final relation in relations) {
    final key = [
      relation.kind.name,
      relation.source,
      relation.target,
      relation.label,
      relation.many.toString(),
      relation.nullable.toString(),
    ].join('|');
    unique.putIfAbsent(key, () => relation);
  }
  final sorted = unique.values.toList()
    ..sort((a, b) {
      final byKind = a.kind.index.compareTo(b.kind.index);
      if (byKind != 0) return byKind;
      final bySource = a.source.compareTo(b.source);
      if (bySource != 0) return bySource;
      final byTarget = a.target.compareTo(b.target);
      if (byTarget != 0) return byTarget;
      return a.label.compareTo(b.label);
    });
  if (sorted.isNotEmpty) buffer.writeln();
  for (final relation in sorted) {
    buffer.writeln('    ${_relationLine(relation)}');
  }
  return buffer.toString();
}

String _relationLine(_Relation relation) {
  final label = relation.label.isEmpty ? '' : ' : ${relation.label}';
  switch (relation.kind) {
    case _RelKind.extendsRel:
      return '${relation.target} <|-- ${relation.source}';
    case _RelKind.implementsRel:
      return '${relation.target} <|.. ${relation.source}$label';
    case _RelKind.composition:
      final right = relation.many
          ? '"*"'
          : (relation.nullable ? '"0..1"' : '"1"');
      return '${relation.source} "1" *-- $right ${relation.target}$label';
    case _RelKind.dependency:
      return '${relation.source} ..> ${relation.target}$label';
  }
}

List<String> omittedFiles(Directory root, String relativeDirectory) {
  final prefix = relativeDirectory.endsWith('/')
      ? relativeDirectory
      : '$relativeDirectory/';
  final covered = <String>{
    for (final group in groups.values)
      for (final file in group.files)
        if (file.path.startsWith(prefix)) file.path,
  };
  final directory = Directory('${root.path}/$relativeDirectory');
  if (!directory.existsSync()) return const [];
  final omitted =
      directory
          .listSync()
          .whereType<File>()
          .map((file) => relativePosix(root.path, file.path))
          .where((path) => path.endsWith('.dart'))
          .where((path) => !isGeneratedPath(path))
          .where((path) => !covered.contains(path))
          .toList()
        ..sort();
  return omitted;
}

List<RenderedDiagram> _renderProviderDiagrams(
  _Library library,
  String id,
  DiagramGroup group,
) {
  final sources = <String, String>{
    for (final file in group.files)
      file.path: File('${library.root.path}/${file.path}').readAsStringSync(),
  };
  final data = analyzeProviderSources(sources);
  const slices = <(String, String, bool Function(String file))>[
    ('services', 'Graf serwisów', _isServiceProviderFile),
    ('app', 'Kontroler, zapis i ustawienia', _isApplicationProviderFile),
  ];
  return [
    for (final slice in slices)
      _providerSlice(
        id: '$id.${slice.$1}',
        title: slice.$2,
        group: group,
        data: data,
        include: slice.$3,
      ),
  ];
}

bool _isServiceProviderFile(String file) =>
    file.endsWith('game_service_providers.dart');

bool _isApplicationProviderFile(String file) => !_isServiceProviderFile(file);

RenderedDiagram _providerSlice({
  required String id,
  required String title,
  required DiagramGroup group,
  required ProviderDiagramData data,
  required bool Function(String file) include,
}) {
  final owners = data.nodes.where((node) => include(node.file)).toList();
  final ownerNames = owners.map((node) => node.name).toSet();
  final edges = data.edges.where((edge) => ownerNames.contains(edge.from));
  final names = <String>{
    ...ownerNames,
    for (final edge in edges) edge.to,
  }.toList()..sort();
  final byName = {for (final node in data.nodes) node.name: node};
  final unresolvedOwners = owners.where((node) => node.unresolved).toList();
  final spots = data.unresolved.where(
    (spot) => ownerNames.contains(spot.owner),
  );
  final buffer = StringBuffer('flowchart LR\n');
  for (final name in names) {
    final node = byName[name];
    final type = node?.exposedType ?? '?';
    buffer.writeln('    ${_flowId(name)}["$name: $type"]');
  }
  final drawn = edges.toList();
  for (final edge in drawn) {
    buffer.writeln('    ${_flowId(edge.from)} --> ${_flowId(edge.to)}');
  }
  if (unresolvedOwners.isNotEmpty) {
    buffer.writeln(
      '    classDef nieustalone fill:#fff8c5,stroke:#9a6700,stroke-width:2px',
    );
    final ids = unresolvedOwners.map((node) => _flowId(node.name)).toList()
      ..sort();
    buffer.writeln('    class ${ids.join(',')} nieustalone');
  }
  final readIndexes = <int>[];
  for (var i = 0; i < drawn.length; i++) {
    if (drawn[i].kind == RefKind.read) readIndexes.add(i);
  }
  if (readIndexes.isNotEmpty) {
    buffer.writeln(
      '    linkStyle ${readIndexes.join(',')} stroke-dasharray:5 5',
    );
  }
  final mermaid = buffer.toString();
  _assertMermaidSafe(id, mermaid);
  final description = StringBuffer()
    ..writeln(group.description)
    ..writeln()
    ..writeln('- Ciągła krawędź: `ref.watch`.')
    ..writeln('- Przerywana krawędź: `ref.read`.')
    ..writeln(
      '- Węzeł w stylu `nieustalone`: w ciele jest dostęp, którego provider skrypt nie rozstrzyga statycznie.',
    );
  final spotList = spots.toList();
  if (spotList.isNotEmpty) {
    description
      ..writeln()
      ..writeln('Miejsca nieustalone:');
    for (final spot in spotList) {
      description.writeln(
        '- `${spot.owner}` w `${spot.file}` linia ${spot.line}: `${spot.snippet}`',
      );
    }
  }
  return RenderedDiagram(
    id: id,
    page: group.page,
    title: title,
    description: description.toString().trimRight(),
    files: [
      for (final file in group.files)
        if (include(file.path)) file.path,
    ],
    typeCount: owners.length,
    mermaid: mermaid,
    countLine: polishCount(
      owners.length,
      one: 'provider',
      few: 'providery',
      many: 'providerów',
    ),
  );
}

RenderedDiagram _renderScreenProviders(
  _Library library,
  String id,
  DiagramGroup group,
) {
  final directory = Directory('${library.root.path}/lib/app/screens');
  final files =
      directory
          .listSync()
          .whereType<File>()
          .map((file) => relativePosix(library.root.path, file.path))
          .where((path) => path.endsWith('_screen.dart'))
          .toList()
        ..sort();
  final lines = <String>[
    '| Ekran | watch | read | nieustalone |',
    '| --- | --- | --- | --- |',
  ];
  final spots = <String>[];
  for (final file in files) {
    final source = File('${library.root.path}/$file').readAsStringSync();
    final uses = extractRefUses(source);
    final watched = <String>{};
    final read = <String>{};
    final unresolved = <RefUse>[];
    for (final use in uses) {
      if (!use.resolved) {
        unresolved.add(use);
        continue;
      }
      if (use.kind == RefKind.watch) {
        watched.add(use.provider!);
      } else {
        read.add(use.provider!);
      }
    }
    final screen = file.split('/').last;
    lines.add(
      '| `$screen` | ${_providerCell(watched)} | ${_providerCell(read)} | '
      '${unresolved.isEmpty ? '—' : 'tak'} |',
    );
    for (final use in unresolved) {
      spots.add(
        '- `$screen` linia ${use.line}: `${use.snippet.replaceAll('|', '/')}`',
      );
    }
  }
  if (spots.isNotEmpty) {
    lines
      ..add('')
      ..add('Miejsca nieustalone:')
      ..add('')
      ..addAll(spots);
  }
  return RenderedDiagram(
    id: id,
    page: group.page,
    title: group.title,
    description:
        '${group.description}\n\n'
        'Kolumna `watch` to `ref.watch`, kolumna `read` to `ref.read`. '
        '`nieustalone` oznacza argument, którego skrypt nie rozstrzyga statycznie.',
    files: files,
    typeCount: files.length,
    mermaid: lines.join('\n'),
    fenced: false,
    countLine: polishCount(
      files.length,
      one: 'ekran',
      few: 'ekrany',
      many: 'ekranów',
    ),
  );
}

String _providerCell(Set<String> names) {
  if (names.isEmpty) return '—';
  final sorted = names.toList()..sort();
  return sorted.map((name) => '`$name`').join(', ');
}

String _flowId(String name) =>
    'n_${name.replaceAll(RegExp(r'[^A-Za-z0-9_]'), '_')}';

String renderReadme(ImportGraph graph, List<RenderedDiagram> diagrams) {
  final buffer = StringBuffer()
    ..writeln(_generatedBanner)
    ..writeln()
    ..write(_renderOverview(graph))
    ..write(_renderLegend())
    ..write(_renderFileIndex(diagrams));
  return buffer.toString();
}

String _renderOverview(ImportGraph graph) {
  final buffer = StringBuffer()
    ..writeln('# Architektura')
    ..writeln()
    ..writeln(
      'Diagramy w tym katalogu powstają ze skryptu '
      '`scripts/gen_class_diagrams.dart`, który czyta AST pakietem `analyzer`. '
      'Pomija `*.g.dart`, `*.freezed.dart` i `lib/l10n/generated`.',
    )
    ..writeln()
    ..writeln('## Przegląd pakietów')
    ..writeln()
    ..writeln(
      'Warstwy są numerowane od dołu. Pakiet z wyższym numerem może '
      'importować pakiet z niższym. Import w drugą stronę jest ruchem w górę.',
    )
    ..writeln()
    ..writeln('| Pakiet | Warstwa |')
    ..writeln('| --- | --- |');
  for (final package in overviewPackages) {
    buffer.writeln('| `${package.id}` | ${package.layer} |');
  }
  buffer
    ..writeln()
    ..writeln('Kolor krawędzi pochodzi z `EdgeKind`:')
    ..writeln();
  for (final kind in EdgeKind.values) {
    buffer.writeln('- ${edgeKindLegend[kind]}');
  }
  buffer
    ..writeln()
    ..writeln(
      'Liczba na strzałce to liczba dyrektyw `import`. `export` oraz importy '
      'warunkowe nie wchodzą do licznika. Import wewnątrz jednego pakietu też nie.',
    )
    ..writeln()
    ..writeln('### Silnie spójne składowe')
    ..writeln();
  if (graph.cycles.isEmpty) {
    buffer.writeln('Brak cykli między pakietami z przeglądu.');
  } else {
    for (final cycle in graph.cycles) {
      buffer.writeln('- ${cycle.map((id) => '`$id`').join(', ')}');
    }
  }
  final marked = graph.edges.where((edge) => edge.kind != EdgeKind.normal);
  buffer
    ..writeln()
    ..writeln('### Oznaczone krawędzie')
    ..writeln();
  if (marked.isEmpty) {
    buffer.writeln('Wszystkie krawędzie są zgodne z warstwą.');
  } else {
    for (final edge in marked) {
      final note = edge.note.isEmpty ? '' : ' — ${edge.note}';
      buffer.writeln(
        '- `${edge.from}` → `${edge.to}` (${edge.count}, '
        '${edgeKindLabel[edge.kind]})$note',
      );
    }
  }
  buffer
    ..writeln()
    ..writeln('```mermaid')
    ..writeln(renderFlowchart(graph).trimRight())
    ..writeln('```')
    ..writeln()
    ..writeln('<details>')
    ..writeln('<summary>Wszystkie krawędzie</summary>')
    ..writeln()
    ..writeln('| Z | Do | Importy | Oznaczenie | Przykład |')
    ..writeln('| --- | --- | --- | --- | --- |');
  for (final edge in graph.edges) {
    buffer.writeln(
      '| `${edge.from}` | `${edge.to}` | ${edge.count} | '
      '${edgeKindLabel[edge.kind]} | '
      '`${edge.sample.replaceAll('|', '/')}` |',
    );
  }
  buffer
    ..writeln()
    ..writeln('</details>')
    ..writeln();
  return buffer.toString();
}

String _renderLegend() {
  final buffer = StringBuffer()
    ..writeln('## Legenda')
    ..writeln()
    ..writeln('### Przegląd')
    ..writeln()
    ..writeln(
      '- Strzałka `A --> B` oznacza, że pliki pakietu A importują pliki pakietu B.',
    )
    ..writeln('- Etykieta to liczba dyrektyw `import`.')
    ..writeln(
      '- Ramka `subgraph` z etykietą `cykl` grupuje silnie spójną składową. '
      'Krawędzie w dół wewnątrz ramki zostają w zwykłym stylu.',
    );
  for (final kind in EdgeKind.values) {
    if (kind == EdgeKind.normal) continue;
    buffer.writeln('- ${edgeKindLegend[kind]}');
  }
  for (final exception in allowedExceptions) {
    buffer.writeln(
      '- Wyjątek `${exception.from}` → `${exception.to}`: ${exception.note}.',
    );
  }
  buffer
    ..writeln()
    ..writeln('### Diagram klas')
    ..writeln()
    ..writeln(
      '- `<<freezed>>` — klasa z adnotacją `@freezed` / `@Freezed` albo z `with _\$…`.',
    )
    ..writeln(
      '- `<<mixin>>`, `<<extension>>`, `<<enumeration>>`, `<<extensionType>>` — rodzaj deklaracji.',
    )
    ..writeln(
      '- `+` oznacza składową publiczną. `\$` na końcu linii oznacza składową statyczną.',
    )
    ..writeln(
      '- Typy generyczne są zapisane jako `List~Player~`. Znaki `<` i `>` rozbijają parser Mermaida na GitHubie.',
    )
    ..writeln('- `<|--` to `extends`.')
    ..writeln(
      '- `<|..` to `implements`, `with` albo ograniczenie `on` mixinu. Etykieta mówi, który z tych trzech przypadków.',
    )
    ..writeln(
      '- `*--` to kompozycja przez typ pola. `"*"` oznacza pole `List`, `Set`, `Iterable` albo `Map`. `"0..1"` oznacza pole nullable. `"1"` oznacza pole wymagane.',
    )
    ..writeln(
      '- `..>` to zależność przez parametr konstruktora albo typ `on` extension.',
    )
    ..writeln(
      '- Pominięte są operatory oraz metody `copyWith`, `toJson`, `fromJson`, `hashCode` i `toString`.',
    )
    ..writeln(
      '- Pole bez adnotacji typu jest zapisane samą nazwą, na przykład `+currentVersion\$`.',
    )
    ..writeln(
      '- Krawędź powstaje tylko wtedy, gdy oba typy są na tym samym diagramie.',
    )
    ..writeln('- Stałe enuma, pola i metody są posortowane alfabetycznie.')
    ..writeln()
    ..writeln('```mermaid')
    ..writeln(_legendDiagram.trimRight())
    ..writeln('```')
    ..writeln();
  return buffer.toString();
}

String _renderFileIndex(List<RenderedDiagram> diagrams) {
  final buffer = StringBuffer()
    ..writeln('## Pliki i regeneracja')
    ..writeln()
    ..writeln('### Pliki')
    ..writeln()
    ..writeln(
      '- `docs/architecture/README.md` — ten przegląd, legenda i instrukcja.',
    )
    ..writeln(
      '- `scripts/gen_class_diagrams.dart` — generator. Mapa grup to `groups`, mapa stron to `pages`.',
    )
    ..writeln(
      '- `scripts/class_diagram_logic.dart` — czyste funkcje używane przez generator i testy.',
    );
  for (final entry in pages.entries) {
    buffer.writeln(
      '- `docs/architecture/${entry.key}` — ${entry.value.title}.',
    );
  }
  buffer
    ..writeln()
    ..writeln('### Diagramy')
    ..writeln();
  for (final diagram in diagrams) {
    buffer
      ..writeln(
        '#### ${diagram.title} (`${diagram.id}`, ${_diagramCount(diagram)})',
      )
      ..writeln()
      ..writeln('Plik: `docs/architecture/${diagram.page}`.')
      ..writeln();
    for (final file in diagram.files) {
      buffer.writeln('- `$file`');
    }
    buffer.writeln();
  }
  buffer
    ..writeln('### Polecenie')
    ..writeln()
    ..writeln(
      'Z katalogu repozytorium, Dartem dostarczonym z Flutter 3.41.4 '
      '(nowszy SDK psuje `pub get` w tym repozytorium):',
    )
    ..writeln()
    ..writeln('```sh')
    ..writeln('dart run scripts/gen_class_diagrams.dart')
    ..writeln('```')
    ..writeln()
    ..writeln(
      'Skrypt nadpisuje markdown w `docs/architecture/`. Wynik jest '
      'deterministyczny: typy, składowe, relacje i krawędzie przeglądu są sortowane.',
    )
    ..writeln();
  return buffer.toString();
}

const _legendDiagram = '''
classDiagram
    class Parent
    class Child
    class Owner {
        <<freezed>>
        +List~Item~ items
    }
    class Item
    class Client
    class Extra {
        <<mixin>>
    }
    class OwnerX {
        <<extension>>
        +int size
    }
    Parent <|-- Child
    Extra <|.. Child : with
    Owner "1" *-- "*" Item : items
    Client ..> Parent : service
    OwnerX ..> Owner : on
''';

String renderFlowchart(ImportGraph graph) {
  final buffer = StringBuffer('flowchart LR\n');
  final inCycle = graph.cycles.expand((cycle) => cycle).toSet();
  for (var i = 0; i < graph.cycles.length; i++) {
    final cycle = graph.cycles[i];
    final label = graph.cycles.length == 1 ? 'cykl' : 'cykl ${i + 1}';
    buffer.writeln('    subgraph cycle_${i + 1} ["$label"]');
    for (final package in overviewPackages) {
      if (!cycle.contains(package.id)) continue;
      buffer.writeln('        ${nodeId(package.id)}["${package.id}"]');
    }
    buffer.writeln('    end');
  }
  for (final package in overviewPackages) {
    if (inCycle.contains(package.id)) continue;
    buffer.writeln('    ${nodeId(package.id)}["${package.id}"]');
  }
  final indexes = <EdgeKind, List<int>>{
    for (final kind in EdgeKind.values)
      if (kind != EdgeKind.normal) kind: <int>[],
  };
  for (var i = 0; i < graph.edges.length; i++) {
    final edge = graph.edges[i];
    buffer.writeln(
      '    ${nodeId(edge.from)} -->|"${edgeCountLabel(edge.count, edge.kind)}"| ${nodeId(edge.to)}',
    );
    indexes[edge.kind]?.add(i);
  }
  for (final kind in EdgeKind.values) {
    final style = edgeKindStyle[kind];
    final ids = indexes[kind];
    if (style == null || ids == null || ids.isEmpty) continue;
    buffer.writeln('    linkStyle ${ids.join(',')} $style');
  }
  return buffer.toString();
}

String renderPage(Directory root, String page, List<RenderedDiagram> diagrams) {
  final info = pages[page];
  if (info == null) {
    throw StateError('Add $page to the pages map before generating it.');
  }
  final buffer = StringBuffer()
    ..writeln(_generatedBanner)
    ..writeln()
    ..writeln('# ${info.title}')
    ..writeln()
    ..writeln(info.intro.trimRight());
  final omittedRoot = info.omittedUnder;
  if (omittedRoot != null) {
    final omitted = omittedFiles(root, omittedRoot);
    buffer.writeln();
    if (omitted.isEmpty) {
      buffer.writeln('Każdy ręczny plik z `$omittedRoot` jest na diagramie.');
    } else {
      for (final path in omitted) {
        buffer.writeln('- `$path`');
      }
    }
  }
  buffer.writeln();
  for (final diagram in diagrams) {
    buffer
      ..writeln('## ${diagram.title}')
      ..writeln()
      ..writeln(diagram.description)
      ..writeln()
      ..writeln(_diagramHeadline(diagram))
      ..writeln();
    if (diagram.fenced) {
      buffer
        ..writeln('```mermaid')
        ..writeln(diagram.mermaid.trimRight())
        ..writeln('```')
        ..writeln();
    } else {
      buffer
        ..writeln(diagram.mermaid.trimRight())
        ..writeln();
    }
  }
  return buffer.toString();
}

String _diagramCount(RenderedDiagram diagram) =>
    diagram.countLine ?? polishTyp(diagram.typeCount);

String _diagramHeadline(RenderedDiagram diagram) {
  final count = _diagramCount(diagram);
  if (diagram.fenced && diagram.mermaid.startsWith('classDiagram')) {
    return '${_capitalize(count)} na diagramie.';
  }
  return '${_capitalize(count)}.';
}

String _capitalize(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1);
}
