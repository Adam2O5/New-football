import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/screens/contract_screen.dart';
import 'package:new_football/app/screens/draft_screen.dart';
import 'package:new_football/app/screens/load_game_screen.dart';
import 'package:new_football/app/screens/main_menu_screen.dart';
import 'package:new_football/app/screens/matchday_screen.dart';
import 'package:new_football/app/screens/new_game_screen.dart';
import 'package:new_football/app/screens/player_detail_screen.dart';
import 'package:new_football/app/screens/settings_screen.dart';
import 'package:new_football/app/screens/shell_screen.dart';
import 'package:new_football/app/screens/prospects_screen.dart';
import 'package:new_football/app/screens/staff_screen.dart';
import 'package:new_football/app/screens/trade_screen.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

final _rootKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const MainMenuScreen(),
      ),
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
            return Scaffold(
              body: Center(
                child: Builder(
                  builder: (context) =>
                      Text(AppLocalizations.of(context)!.router_noMatchData),
                ),
              ),
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
        builder: (context, state) => const TradeScreen(),
      ),
      GoRoute(
        path: '/game/contracts',
        builder: (context, state) => const ContractScreen(),
      ),
      GoRoute(
        path: '/game/staff',
        builder: (context, state) => const StaffScreen(),
      ),
      GoRoute(
        path: '/game/prospects',
        builder: (context, state) => const ProspectsScreen(),
      ),
    ],
  );
});
