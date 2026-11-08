import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/screens/search_filters_screen.dart';
import 'package:new_football/app/screens/free_agency_screen.dart';
import 'package:new_football/app/screens/staff_screen.dart';
import 'package:new_football/app/screens/rankings_screen.dart';
import 'package:new_football/core/services/contract_service.dart';
import 'package:new_football/app/utils/squad_tile_metrics.dart';
import 'package:new_football/app/utils/color_interpolation.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/services/contract_market_service.dart';
import 'package:new_football/core/services/day_pipeline.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/core/services/message_service.dart';
import 'package:new_football/core/services/search_filter_matching.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';
import '../helpers/fixtures/game_fixtures.dart';
import '../helpers/widgets/career_dashboard_harness.dart';
import '../helpers/widgets/stateful_screen_harness.dart';

GameMessage _message(
  String id, {
  int year = 2026,
  MessagePriority priority = MessagePriority.normal,
  String? group,
  bool read = false,
}) => GameMessage(
  id: id,
  type: MessageType.ovrDigest,
  priority: priority,
  seasonYear: year,
  week: 1,
  titleKey: 'msg_ovrDigest_title',
  bodyKey: 'msg_ovrDigest_body',
  args: const {'count': 1},
  groupKey: group,
  read: read,
);

void main() {
  final league = GameFactory()
      .create(
        const NewGameRequest(
          saveName: 'I09',
          playerTeamId: 'team_europe_0',
          seed: 42,
        ),
      )
      .leagueState
      .copyWith(inbox: const Inbox());

  test('digest reads configured minimum at the exact boundary', () {
    const balance = MessagesBalance(digestMinItems: 2);
    final first = const Inbox().addMessage(
      _message('a', group: 'ovr:test'),
      balance: balance,
    );
    expect(first.messages.single.kind, isNot('digest'));
    final result = first.addMessage(
      _message('b', group: 'ovr:test'),
      balance: balance,
    );
    expect(result.messages.single.kind, 'digest');
    expect(result.messages.single.args['count'], 2);
    expect(result.archive, hasLength(2));
  });

  test('unread limit marks only oldest unread messages read', () {
    const balance = MessagesBalance(maxUnreadInbox: 1);
    var inbox = const Inbox();
    for (final id in ['a', 'b', 'c']) {
      inbox = inbox.addMessage(_message(id), balance: balance);
    }
    expect(inbox.unread.map((m) => m.id), ['c']);
    expect(inbox.messages, hasLength(3));
  });

  test('inbox cap evicts oldest read messages but protects pending urgent', () {
    const balance = MessagesBalance(maxInboxMessages: 1);
    final inbox = Inbox(
      messages: [
        _message('read', read: true),
        _message('urgent', priority: MessagePriority.urgent, read: true),
      ],
    ).addMessage(_message('new'), balance: balance);
    expect(inbox.messages.map((m) => m.id), ['urgent', 'new']);
    expect(inbox.pendingUrgent.single.id, 'urgent');
  });

  test('archive cap is used by muted send, schedule and season retention', () {
    const balance = MessagesBalance(
      maxArchiveMessages: 1,
      inboxRetentionSeasons: 1,
    );
    final inbox = const Inbox()
        .addMessage(
          _message('a', priority: MessagePriority.silenced),
          balance: balance,
        )
        .scheduleMessage(
          _message('b', priority: MessagePriority.silenced),
          balance: balance,
        );
    expect(inbox.archive.single.id, 'b');
    final result = inbox
        .copyWith(messages: [_message('old', year: 2025), _message('current')])
        .retainSeasons(2026, balance: balance);
    expect(result.messages.single.id, 'current');
    expect(result.archive.single.id, 'old');
  });

  test('retention keeps configured seasons including exact lower boundary', () {
    const balance = MessagesBalance(inboxRetentionSeasons: 3);
    final result = Inbox(
      messages: [for (var y = 2022; y <= 2026; y++) _message('$y', year: y)],
      scheduled: [
        _message('scheduled-old', year: 2023),
        _message('scheduled-kept', year: 2024),
      ],
    ).retainSeasons(2026, balance: balance);
    expect(result.messages.map((m) => m.seasonYear), [2024, 2025, 2026]);
    expect(result.scheduled.single.id, 'scheduled-kept');
    expect(result.archive.map((m) => m.id), ['2022', '2023', 'scheduled-old']);
  });

  test('message service applies injected limits on real send', () {
    const balance = BalanceConfig(
      messages: MessagesBalance(maxUnreadInbox: 1, maxInboxMessages: 1),
    );
    var result = league.copyWith(
      messageSettings: const MessageSettings(
        overrides: {MessageType.ovrDigest: NotificationLevel.normal},
      ),
    );
    for (var i = 0; i < 3; i++) {
      result = MessageService(balance: balance).send(
        result,
        type: MessageType.ovrDigest,
        args: {'count': i + 1, 'week': result.currentWeek},
        dedupKey: 'i09:$i',
        groupKey: 'separate:$i',
      );
    }
    expect(result.inbox.messages, hasLength(1));
    expect(result.inbox.unread.single.args['count'], 3);
  });

  test('pipeline scheduled delivery forwards digest and unread policy', () {
    const balance = BalanceConfig(
      messages: MessagesBalance(digestMinItems: 2, maxUnreadInbox: 1),
    );
    final input = league.copyWith(
      currentWeek: 1,
      currentDay: 1,
      inbox: Inbox(
        scheduled: [
          _message('a', group: 'ovr:test'),
          _message('b', group: 'ovr:test'),
        ],
      ),
    );
    final result = DayPipeline(
      balance: balance,
    ).deliverStartOfDay(input, resolveExpired: false);
    expect(result.inbox.scheduled, isEmpty);
    expect(result.inbox.messages.single.kind, 'digest');
    expect(result.inbox.unread, hasLength(1));
  });

  test(
    'potential age and empty pick slider read independent UI configuration',
    () {
      const balance = BalanceConfig(
        ui: UiBalance(
          developingPotentialMaxAge: 23,
          pickFilterFallbackYears: 7,
        ),
      );
      expect(isDevelopingPotentialAge(23, balance), isTrue);
      expect(isDevelopingPotentialAge(24, balance), isFalse);
      expect(potentialStarColor(24, balance), potentialStarColor(27));
      expect(yearSliderBounds([], fallbackYear: 2026, balance: balance), (
        min: 2026,
        max: 2033,
        divisions: 7,
      ));
    },
  );

  for (final language in ['pl', 'en']) {
    test('rule texts in $language interpolate actual domain limits', () async {
      final text = await AppLocalizations.delegate.load(Locale(language));
      expect(text.home_simulateHour(2, 7), contains('2/7'));
      expect(text.freeAgency_rosterUsage(12, 28), contains('12/28'));
      expect(text.freeAgency_invalidOffer(2, 6), contains('2–6'));
      expect(text.staff_yearsRange(2, 7), contains('2'));
      expect(text.staff_yearsRange(2, 7), contains('7'));
      expect(text.squad_belowXi(9), contains('9'));
      expect(
        text.msg_draftedRightsReminder_body('Player', 12, 28),
        contains('12/28'),
      );
      expect(text.msg_trade_hardRejected_body(17), contains('17'));
      expect(text.draft_injuryProneShort(4, 12), contains('4/12'));
      expect(text.draft_determinationShort(4, 12), contains('4/12'));
    });
  }

  testWidgets('all search ranges and slider steps use UI configuration', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1600, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    const balance = BalanceConfig(
      ui: UiBalance(
        playerFilterAgeMin: 19,
        playerFilterAgeMax: 39,
        prospectFilterAgeMin: 17,
        prospectFilterAgeMax: 22,
        filterOvrMin: 61,
        filterOvrMax: 91,
        filterSalaryMax: 8000000,
        filterSalaryStep: 2000000,
        filterPotentialMin: 1,
        filterPotentialMax: 4,
        filterPotentialStep: 1,
        filterContractYearsMin: 1,
        filterContractYearsMax: 8,
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [balanceProvider.overrideWithValue(balance)],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SearchFiltersScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    List<RangeSlider> sliders() => tester
        .widgetList<RangeSlider>(find.byType(RangeSlider).hitTestable())
        .toList();
    expect(
      sliders().any((s) => s.min == 19 && s.max == 39 && s.divisions == 20),
      isTrue,
    );
    expect(
      sliders().any((s) => s.min == 61 && s.max == 91 && s.divisions == 30),
      isTrue,
    );
    expect(
      sliders().any((s) => s.min == 0 && s.max == 8000000 && s.divisions == 4),
      isTrue,
    );
    expect(
      sliders().any((s) => s.min == 1 && s.max == 8 && s.divisions == 7),
      isTrue,
    );
    expect(
      sliders().any((s) => s.min == 1 && s.max == 4 && s.divisions == 3),
      isTrue,
    );
    tester.widget<TabBar>(find.byType(TabBar)).controller!.index = 1;
    await tester.pumpAndSettle();
    expect(
      sliders().any((s) => s.min == 17 && s.max == 22 && s.divisions == 5),
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });
  for (final kind in ['fa', 'staff']) {
    testWidgets('$kind rejects years outside the injected domain range', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1600, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      const balance = BalanceConfig(
        contracts: ContractNegBalance(playerMinYears: 2, playerMaxYears: 3),
        staff: StaffBalance(minContractYears: 2, maxContractYears: 3),
        ui: UiBalance(freeAgencyOvrOptions: [0, 65, 85]),
      );
      final input = marketFormLeague();
      final screen = kind == 'fa'
          ? const FreeAgencyScreen()
          : const StaffScreen();
      await tester.pumpWidget(
        dashboardApp(screen, saveForLeague(input), balance: balance),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find
            .widgetWithText(ListTile, kind == 'fa' ? 'R12 Agent' : 'R12 Scout')
            .first,
      );
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(
        tester.element(find.byType(screen.runtimeType)),
      )!;
      final years = labelledField(
        kind == 'fa' ? l10n.freeAgency_offerYears : l10n.contract_offerYears,
      );
      await tester.ensureVisible(years);
      await tester.enterText(years, '4');
      await tester.pumpAndSettle();
      if (kind == 'fa') {
        final filter = tester.widget<DropdownButton<int>>(
          find.byType(DropdownButton<int>),
        );
        expect(filter.items!.map((item) => item.value), [0, 65, 85]);
        final button = find.widgetWithText(
          FilledButton,
          l10n.freeAgency_submitOffer,
        );
        await tester.ensureVisible(button);
        await tester.tap(button);
        await tester.pumpAndSettle();
        expect(find.text(l10n.freeAgency_invalidOffer(2, 3)), findsOneWidget);
        expect(
          ContractService(balance: balance)
              .validateOffer(
                team: input.playerTeam!,
                player: input.freeAgents.single,
                offer: const ContractOffer(salary: 1000000, years: 4),
              )
              .ok,
          isFalse,
        );
      } else {
        expect(find.text(l10n.staff_yearsRange(2, 3)), findsOneWidget);
        final button = find.widgetWithText(
          FilledButton,
          l10n.contract_submitOffer,
        );
        expect(tester.widget<FilledButton>(button).onPressed, isNull);
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('young ranking uses configured age interval and top-list limit', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1600, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final team = league.playerTeam!;
    final roster = [
      for (var i = 0; i < 4; i++) team.roster[i].copyWith(age: 22 + i),
    ];
    final input = league.copyWith(teams: [team.copyWith(roster: roster)]);
    const balance = BalanceConfig(
      ui: UiBalance(
        youngRankingAgeMin: 22,
        youngRankingAgeMax: 24,
        rankingPlayerLimit: 1,
      ),
    );
    await tester.pumpWidget(
      dashboardApp(
        const RankingsScreen(),
        saveForLeague(input),
        balance: balance,
      ),
    );
    await tester.pumpAndSettle();
    DefaultTabController.of(tester.element(find.byType(TabBar))).index = 2;
    await tester.pumpAndSettle();
    final table = tester.widget<DataTable>(
      find.byType(DataTable).hitTestable(),
    );
    expect(table.rows, hasLength(1));
    expect(tester.takeException(), isNull);
  });
  test(
    'QO default term comes from contract rules while explicit invalid terms fail',
    () {
      const balance = BalanceConfig(
        contracts: ContractNegBalance(qualifyingOfferYears: 2),
      );
      final team = league.playerTeam!;
      final player = team.roster.first.copyWith(
        age: 25,
        contract: team.roster.first.contract.copyWith(
          isRookieScale: true,
          yearsRemaining: 1,
          firstSeason: 2026,
          lastSeason: 2026,
        ),
      );
      final input = league.copyWith(
        teams: [
          team.copyWith(roster: [player]),
        ],
        currentWeek: 46,
        currentDay: 2,
      );
      final service = ContractMarketService(balance: balance);
      final result = service.submitQualifyingOffer(
        league: input,
        ownerTeamId: team.id,
        playerId: player.id,
      );
      expect(result, isNotNull);
      expect(result!.rfaQualifyingOffers.single.years, 2);
      expect(
        service.submitQualifyingOffer(
          league: input,
          ownerTeamId: team.id,
          playerId: player.id,
          years: 6,
        ),
        isNull,
      );
    },
  );
  test('form display range remains independent of the gameplay range', () {
    expect(clampedFormValue(-1), 0);
    expect(formFillForValue(5), 0.5);
    const balance = BalanceConfig(
      ui: UiBalance(formDisplayMin: 2, formDisplayMax: 6),
    );
    expect(clampedFormValue(1, balance), 2);
    expect(clampedFormValue(7, balance), 6);
    expect(formFillForValue(4, balance), 0.5);
    expect(balance.player.formMin, 1);
  });
}
