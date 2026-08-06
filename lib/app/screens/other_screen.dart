import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

class OtherScreen extends StatelessWidget {
  const OtherScreen({super.key});

  void _showWorkInProgress(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.other_workInProgress)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = <(IconData, String, String?)>[
      (Icons.swap_horiz, l10n.other_tradeHistory, null),
      (Icons.account_balance_wallet_outlined, l10n.other_finances, null),
      (Icons.description_outlined, l10n.other_contracts, null),
      (Icons.person_search_outlined, l10n.other_freeAgency, null),
      (Icons.emoji_people_outlined, l10n.other_prospects, '/game/prospects'),
      (Icons.groups_outlined, l10n.other_staff, null),
      (Icons.trending_up, l10n.other_development, '/game/development'),
      (Icons.bar_chart, l10n.other_playerStats, null),
      (Icons.emoji_events_outlined, l10n.other_rewards, null),
      (Icons.search, l10n.other_search, null),
      (Icons.how_to_vote_outlined, l10n.other_draftHistory, null),
      (Icons.leaderboard_outlined, l10n.other_rankings, null),
      (Icons.visibility_outlined, l10n.other_watchlist, null),
    ];

    return ScreenBackground(
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 6),
        itemBuilder: (context, i) {
          final (icon, label, route) = items[i];
          return Card(
            child: ListTile(
              leading: Icon(icon),
              title: Text(label),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                if (route != null) {
                  context.push(route);
                } else {
                  _showWorkInProgress(context);
                }
              },
            ),
          );
        },
      ),
    );
  }
}
