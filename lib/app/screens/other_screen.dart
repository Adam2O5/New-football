import 'package:flutter/material.dart';

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
    final items = <(IconData, String)>[
      (Icons.swap_horiz, l10n.other_tradeHistory),
      (Icons.account_balance_wallet_outlined, l10n.other_finances),
      (Icons.description_outlined, l10n.other_contracts),
      (Icons.person_search_outlined, l10n.other_freeAgency),
      (Icons.emoji_people_outlined, l10n.other_prospects),
      (Icons.groups_outlined, l10n.other_staff),
      (Icons.trending_up, l10n.other_development),
      (Icons.bar_chart, l10n.other_playerStats),
      (Icons.emoji_events_outlined, l10n.other_rewards),
      (Icons.search, l10n.other_search),
      (Icons.how_to_vote_outlined, l10n.other_draftHistory),
      (Icons.leaderboard_outlined, l10n.other_rankings),
      (Icons.visibility_outlined, l10n.other_watchlist),
    ];

    return ScreenBackground(
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 6),
        itemBuilder: (context, i) {
          final (icon, label) = items[i];
          return Card(
            child: ListTile(
              leading: Icon(icon),
              title: Text(label),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showWorkInProgress(context),
            ),
          );
        },
      ),
    );
  }
}
