import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:new_football/app/l10n/enum_labels.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final league = ref.watch(activeLeagueProvider);
    if (league == null) {
      return Center(child: Text(l10n.standings_noLeague));
    }

    final messages = [...league.inbox.messages]
      ..sort((a, b) {
        final u = (b.priority == MessagePriority.urgent ? 1 : 0).compareTo(
          a.priority == MessagePriority.urgent ? 1 : 0,
        );
        if (u != 0) return u;
        return b.week.compareTo(a.week);
      });

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Row(
            children: [
              Text(l10n.inbox_title, style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _openSettings(context, ref),
                icon: const Icon(Icons.tune, size: 18),
                label: Text(l10n.inbox_notifications),
              ),
            ],
          ),
        ),
        Expanded(
          child: messages.isEmpty
              ? Center(child: Text(l10n.inbox_empty))
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 6),
                  itemBuilder: (context, i) {
                    final m = messages[i];
                    final urgent = m.priority == MessagePriority.urgent;
                    return Card(
                      color: urgent
                          ? Theme.of(context).colorScheme.errorContainer
                                .withValues(alpha: m.read ? 0.35 : 0.7)
                          : null,
                      child: ListTile(
                        leading: Icon(
                          urgent ? Icons.priority_high : Icons.mail_outline,
                          color: urgent
                              ? Theme.of(context).colorScheme.error
                              : (m.read
                                    ? null
                                    : Theme.of(context).colorScheme.primary),
                        ),
                        title: Text(
                          m.title,
                          style: TextStyle(
                            fontWeight: m.read
                                ? FontWeight.normal
                                : FontWeight.bold,
                            color: urgent
                                ? Theme.of(context).colorScheme.error
                                : null,
                          ),
                        ),
                        subtitle: Text(l10n.inbox_messageSubtitle(m.week, m.body)),
                        isThreeLine: true,
                        onTap: () {
                          if (!m.read) {
                            ref
                                .read(gameControllerProvider.notifier)
                                .markMessageRead(m.id);
                          }
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _openSettings(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final league = ref.read(activeLeagueProvider);
    if (league == null) return;
    var settings = league.messageSettings;
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return AlertDialog(
              title: Text(l10n.inbox_settingsTitle),
              content: SizedBox(
                width: 360,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final type in [
                      MessageType.matchResult,
                      MessageType.injury,
                      MessageType.trade,
                      MessageType.contractOffer,
                      MessageType.draftPick,
                      MessageType.award,
                    ])
                      ListTile(
                        dense: true,
                        title: Text(messageTypeLabel(ctx, type)),
                        trailing: DropdownButton<NotificationLevel>(
                          value: settings.levelFor(type),
                          items: NotificationLevel.values
                              .map(
                                (l) => DropdownMenuItem(
                                  value: l,
                                  child: Text(notificationLevelLabel(ctx, l)),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v == null) return;
                            setLocal(() {
                              settings = settings.copyWith(
                                overrides: {...settings.overrides, type: v},
                              );
                            });
                          },
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l10n.common_cancel),
                ),
                FilledButton(
                  onPressed: () {
                    ref.read(gameControllerProvider.notifier).updateLeague(
                      (l) => l.copyWith(messageSettings: settings),
                    );
                    Navigator.pop(ctx);
                  },
                  child: Text(l10n.common_save),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
