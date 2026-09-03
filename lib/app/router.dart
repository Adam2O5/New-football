import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/screens/contract_screen.dart';
import 'package:new_football/app/screens/draft_history_screen.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/screens/draft_screen.dart';
import 'package:new_football/app/screens/load_game_screen.dart';
import 'package:new_football/app/screens/main_menu_screen.dart';
import 'package:new_football/app/screens/matchday_screen.dart';
import 'package:new_football/app/screens/new_game_screen.dart';
import 'package:new_football/app/screens/player_detail_screen.dart';
import 'package:new_football/app/screens/settings_screen.dart';
import 'package:new_football/app/screens/shell_screen.dart';
import 'package:new_football/app/screens/development_screen.dart';
import 'package:new_football/app/screens/finance_screen.dart';
import 'package:new_football/app/screens/free_agency_screen.dart';
import 'package:new_football/app/screens/rankings_screen.dart';
import 'package:new_football/app/screens/rewards_screen.dart';
import 'package:new_football/app/screens/search_screen.dart';
import 'package:new_football/app/screens/search_filters_screen.dart';
import 'package:new_football/app/screens/player_stats_screen.dart';
import 'package:new_football/app/screens/team_overview_screen.dart';
import 'package:new_football/app/screens/lottery_screen.dart';
import 'package:new_football/app/screens/prospects_screen.dart';
import 'package:new_football/app/screens/staff_screen.dart';
import 'package:new_football/app/screens/trade_history_screen.dart';
import 'package:new_football/app/screens/trade_screen.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

final _rootKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/',
    redirect: (context, state) {
      final isGameRoute =
          state.matchedLocation == '/game' ||
          state.matchedLocation.startsWith('/game/');
      final hasActiveGame = ref.read(gameControllerProvider).value != null;
      if (isGameRoute && !hasActiveGame) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const MainMenuScreen()),
      GoRoute(
        path: '/new-game',
        builder: (context, state) => const NewGameScreen(),
      ),
      GoRoute(
        path: '/load-game',
        builder: (context, state) => const LoadGameScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/game',
        builder: (context, state) {
          final tab = state.extra is int ? state.extra as int : null;
          return ShellScreen(initialTab: tab);
        },
      ),
      GoRoute(
        path: '/game/match',
        builder: (context, state) {
          final match = state.extra;
          if (match is! ScheduledMatch) {
            final l10n = AppLocalizations.of(context)!;
            return Scaffold(
              appBar: AppBar(
                title: Text(l10n.matchday_defaultTitle),
                leading: IconButton(
                  tooltip: l10n.common_cancel,
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go('/game'),
                ),
              ),
              body: Center(child: Text(l10n.router_noMatchData)),
            );
          }
          return MatchdayScreen(match: match);
        },
      ),
      GoRoute(
        path: '/game/player/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PlayerDetailScreen(playerId: id);
        },
      ),
      GoRoute(
        path: '/game/draft',
        builder: (context, state) => const DraftScreen(),
      ),
      GoRoute(
        path: '/game/trade',
        builder: (context, state) => TradeScreen(
          initialOwnPlayerId: state.uri.queryParameters['ownPlayerId'],
          initialTargetTeamId: state.uri.queryParameters['targetTeamId'],
          initialTheirPlayerId: state.uri.queryParameters['theirPlayerId'],
          initialTheirPickId: state.uri.queryParameters['theirPickId'],
          initialTradeOfferId: state.uri.queryParameters['tradeOfferId'],
        ),
      ),
      GoRoute(
        path: '/game/trade-history',
        builder: (context, state) => const TradeHistoryScreen(),
      ),
      GoRoute(
        path: '/game/contracts',
        builder: (context, state) => const ContractScreen(),
      ),
      GoRoute(
        path: '/game/free-agency',
        builder: (context, state) => const FreeAgencyScreen(),
      ),
      GoRoute(
        path: '/game/staff',
        builder: (context, state) => const StaffScreen(),
      ),
      GoRoute(
        path: '/game/prospects',
        builder: (context, state) => ProspectsScreen(
          initialWatchOnly: state.uri.queryParameters['watchlist'] == 'true',
          initialCombine: state.uri.queryParameters['combine'] == 'true',
          initialHighlightProspectId:
              state.uri.queryParameters['highlightProspectId'],
        ),
      ),
      GoRoute(
        path: '/game/lottery',
        builder: (context, state) => const LotteryScreen(),
      ),
      GoRoute(
        path: '/game/finance',
        builder: (context, state) => const FinanceScreen(),
      ),
      GoRoute(
        path: '/game/development',
        builder: (context, state) => const DevelopmentScreen(),
      ),
      GoRoute(
        path: '/game/draft-history',
        builder: (context, state) => const DraftHistoryScreen(),
      ),
      GoRoute(
        path: '/game/rankings',
        builder: (context, state) => const RankingsScreen(),
      ),
      GoRoute(
        path: '/game/stats',
        builder: (context, state) => const StatsScreen(),
      ),
      GoRoute(
        path: '/game/team-overview',
        builder: (context, state) => const TeamOverviewScreen(),
      ),
      GoRoute(
        path: '/game/rewards',
        builder: (context, state) => const RewardsScreen(),
      ),
      GoRoute(
        path: '/game/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/game/search/filters',
        builder: (context, state) => const SearchFiltersScreen(),
      ),
    ],
  );
});
