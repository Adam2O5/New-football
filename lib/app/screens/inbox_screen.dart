import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/l10n/enum_labels.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/core/balance/message_catalog.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

/// Returns messages from the selected inbox/archive bucket and domain.
List<GameMessage> inboxMessagesForDomain(
  Inbox inbox,
  MessageDomain? domain, {
  bool archive = false,
}) {
  final source = archive ? inbox.archive : inbox.messages;
  return source
      .where((message) => domain == null || message.domain == domain)
      .toList();
}

/// Sorts urgent messages first, then unread messages, then newest calendar date.
List<GameMessage> sortInboxMessages(Iterable<GameMessage> messages) {
  final sorted = [...messages];
  sorted.sort((a, b) {
    final urgent = (b.priority == MessagePriority.urgent ? 1 : 0).compareTo(
      a.priority == MessagePriority.urgent ? 1 : 0,
    );
    if (urgent != 0) return urgent;
    final unread = (!b.read ? 1 : 0).compareTo(!a.read ? 1 : 0);
    if (unread != 0) return unread;
    final season = b.seasonYear.compareTo(a.seasonYear);
    if (season != 0) return season;
    final week = b.week.compareTo(a.week);
    if (week != 0) return week;
    final day = b.day.compareTo(a.day);
    if (day != 0) return day;
    return (b.hour ?? 0).compareTo(a.hour ?? 0);
  });
  return sorted;
}

class InboxScreen extends ConsumerStatefulWidget {
  const InboxScreen({super.key});

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

enum _InboxBucket { inbox, archive }

class _InboxScreenState extends ConsumerState<InboxScreen> {
  MessageDomain? _domain;
  _InboxBucket _bucket = _InboxBucket.inbox;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final league = ref.watch(activeLeagueProvider);
    if (league == null) {
      return Center(child: Text(l10n.standings_noLeague));
    }

    final archive = _bucket == _InboxBucket.archive;
    final selected = sortInboxMessages(
      inboxMessagesForDomain(league.inbox, _domain, archive: archive),
    );
    final unreadCount = league.inbox.unread.length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Badge(
                  isLabelVisible: unreadCount > 0,
                  label: Text('$unreadCount'),
                  child: const Icon(Icons.mail_outline),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.inbox_title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: l10n.inbox_notifications,
                  onPressed: () => _openSettings(context),
                  icon: const Icon(Icons.tune),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Row(
            children: [
              Expanded(
                child: SegmentedButton<_InboxBucket>(
                  segments: [
                    ButtonSegment(
                      value: _InboxBucket.inbox,
                      label: Text(l10n.inbox_tabInbox),
                      icon: const Icon(Icons.inbox_outlined),
                    ),
                    ButtonSegment(
                      value: _InboxBucket.archive,
                      label: Text(l10n.inbox_tabArchive),
                      icon: const Icon(Icons.archive_outlined),
                    ),
                  ],
                  selected: {_bucket},
                  onSelectionChanged: (value) {
                    setState(() => _bucket = value.first);
                  },
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 52,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            scrollDirection: Axis.horizontal,
            children: [
              _domainChip(context, null, l10n.inbox_filterAll),
              for (final domain in MessageDomain.values)
                _domainChip(
                  context,
                  domain,
                  messageDomainLabel(context, domain),
                ),
            ],
          ),
        ),
        Expanded(
          child: selected.isEmpty
              ? Center(
                  child: Text(
                    archive ? l10n.inbox_emptyArchive : l10n.inbox_empty,
                  ),
                )
              : archive
              ? _archiveList(context, selected)
              : _inboxList(context, selected),
        ),
      ],
    );
  }

  Widget _domainChip(
    BuildContext context,
    MessageDomain? domain,
    String label,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label),
        selected: _domain == domain,
        onSelected: (_) => setState(() => _domain = domain),
      ),
    );
  }

  Widget _inboxList(BuildContext context, List<GameMessage> messages) {
    final urgent = messages
        .where((message) => message.priority == MessagePriority.urgent)
        .toList();
    final unread = messages
        .where(
          (message) =>
              message.priority != MessagePriority.urgent && !message.read,
        )
        .toList();
    final read = messages
        .where(
          (message) =>
              message.priority != MessagePriority.urgent && message.read,
        )
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
      children: [
        if (urgent.isNotEmpty) ...[
          _sectionHeader(
            context,
            AppLocalizations.of(context)!.inbox_sectionUrgent,
          ),
          for (final message in urgent) _messageCard(context, message),
        ],
        if (unread.isNotEmpty) ...[
          _sectionHeader(
            context,
            AppLocalizations.of(context)!.inbox_sectionUnread,
          ),
          for (final message in unread) _messageCard(context, message),
        ],
        if (read.isNotEmpty) ...[
          _sectionHeader(
            context,
            AppLocalizations.of(context)!.inbox_sectionRead,
          ),
          for (final message in read) _messageCard(context, message),
        ],
      ],
    );
  }

  Widget _archiveList(BuildContext context, List<GameMessage> messages) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
      children: [
        for (final message in messages) _messageCard(context, message),
      ],
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
      child: Text(title, style: Theme.of(context).textTheme.titleSmall),
    );
  }

  Widget _messageCard(BuildContext context, GameMessage message) {
    final l10n = AppLocalizations.of(context)!;
    final urgent = message.priority == MessagePriority.urgent;
    return Card(
      color: urgent
          ? Theme.of(context).colorScheme.errorContainer.withValues(
              alpha: message.read ? 0.35 : 0.75,
            )
          : null,
      child: ListTile(
        leading: urgent
            ? Icon(Icons.flag, color: Theme.of(context).colorScheme.error)
            : Icon(
                message.read ? Icons.drafts_outlined : Icons.mark_email_unread,
                color: message.read
                    ? null
                    : Theme.of(context).colorScheme.primary,
              ),
        title: Text(
          _messageTitle(context, message),
          style: TextStyle(
            fontWeight: message.read ? FontWeight.normal : FontWeight.bold,
            color: urgent ? Theme.of(context).colorScheme.error : null,
          ),
        ),
        subtitle: Text(
          l10n.inbox_metadata(
            message.week,
            message.day,
            messageDomainLabel(context, message.domain),
          ),
        ),
        trailing: message.decision == null
            ? null
            : const Icon(Icons.how_to_vote_outlined),
        onTap: () => _openDetails(context, message),
      ),
    );
  }

  String _messageTitle(BuildContext context, GameMessage message) {
    final legacy = message.args['_legacyTitle'];
    if (legacy is String && legacy.isNotEmpty) return legacy;
    return messageTypeLabel(context, message.type);
  }

  String _messageBody(BuildContext context, GameMessage message) {
    final l10n = AppLocalizations.of(context)!;
    final legacy = message.args['_legacyBody'];
    if (legacy is String && legacy.isNotEmpty) return legacy;
    final inline = message.args['message'];
    if (inline != null) return inline.toString();
    return l10n.inbox_bodyFallback(messageTypeLabel(context, message.type));
  }

  Future<void> _openDetails(BuildContext context, GameMessage message) async {
    if (!message.read && _bucket == _InboxBucket.inbox) {
      await ref
          .read(gameControllerProvider.notifier)
          .markMessageRead(message.id);
    }
    if (!context.mounted) return;
    final league = ref.read(activeLeagueProvider);
    final digestIds = (message.payload['messageIds'] as List<dynamic>?)
        ?.map((id) => id.toString())
        .toSet();
    final digestMembers = digestIds == null || league == null
        ? const <(String, String)>[]
        : [
            for (final member in [
              ...league.inbox.archive,
              ...league.inbox.messages,
            ])
              if (digestIds.contains(member.id))
                (_messageTitle(context, member), _messageBody(context, member)),
          ];
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _MessageDetails(
        message: message,
        title: _messageTitle(context, message),
        body: _messageBody(context, message),
        onDecision: (optionId) async {
          await ref
              .read(gameControllerProvider.notifier)
              .resolveMessageDecision(message.id, optionId);
          if (sheetContext.mounted) Navigator.pop(sheetContext);
        },
        onAcknowledge: () async {
          await ref
              .read(gameControllerProvider.notifier)
              .acknowledgeMessage(message.id);
          if (sheetContext.mounted) Navigator.pop(sheetContext);
        },
        onAction: (action) => _runAction(context, message, action),
        digestMembers: digestMembers,
      ),
    );
  }

  Future<void> _runAction(
    BuildContext context,
    GameMessage message,
    MessageAction action,
  ) async {
    final controller = ref.read(gameControllerProvider.notifier);
    await controller.markMessageRead(message.id);
    final payload = message.payload;
    final playerId = payload['playerId']?.toString();
    if (playerId != null && playerId.isNotEmpty) {
      if (context.mounted) context.push('/game/player/$playerId');
      return;
    }
    final route = switch (message.type) {
      MessageType.draftPick || MessageType.draftPickLeague => '/game/draft',
      MessageType.trade || MessageType.tradeOffer => '/game/trade',
      MessageType.contractOffer ||
      MessageType.contractSigned => '/game/contracts',
      MessageType.scoutReport => '/game/prospects?watchlist=true',
      MessageType.staffGrowth ||
      MessageType.staffHired ||
      MessageType.staffFired => '/game/staff',
      MessageType.apronWarning ||
      MessageType.capUpdateTv ||
      MessageType.staffCapViolation => '/game/finance',
      _ => null,
    };
    if (route != null && context.mounted) {
      context.push(route);
    } else if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_actionLabel(context, action))));
    }
  }

  String _actionLabel(BuildContext context, MessageAction action) {
    final l10n = AppLocalizations.of(context)!;
    final id = action.id.toLowerCase();
    if (id.contains('accept') || id == 'finalize')
      return l10n.inbox_actionAccept;
    if (id.contains('decline') || id.contains('reject') || id == 'cancel') {
      return l10n.inbox_actionDecline;
    }
    if (id.contains('counter')) return l10n.inbox_actionCounter;
    if (id.contains('open') || id.contains('watchlist'))
      return l10n.inbox_actionOpen;
    return l10n.inbox_actionFallback;
  }

  Future<void> _openSettings(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final league = ref.read(activeLeagueProvider);
    if (league == null) return;
    var settings = league.messageSettings;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setLocal) {
          return AlertDialog(
            title: Text(l10n.inbox_settingsTitle),
            content: SizedBox(
              width: 440,
              height: 560,
              child: ListView(
                children: [
                  Text(
                    l10n.inbox_settingsDomain,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  for (final domain in MessageDomain.values)
                    _settingsRow(
                      context,
                      messageDomainLabel(context, domain),
                      settings.domainOverrides[domain] ??
                          NotificationLevel.auto,
                      (level) {
                        if (level == NotificationLevel.muted &&
                            _domainHasDecision(domain)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                l10n.inbox_settingsDomainDecisionMuted,
                              ),
                            ),
                          );
                          return;
                        }
                        setLocal(
                          () => settings = settings.withDomainLevel(
                            domain,
                            level,
                          ),
                        );
                      },
                    ),
                  const Divider(),
                  Text(
                    l10n.inbox_settingsType,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  for (final type in MessageType.values)
                    _settingsRow(
                      context,
                      messageTypeLabel(context, type),
                      settings.overrides[type] ?? NotificationLevel.auto,
                      (level) {
                        try {
                          setLocal(
                            () =>
                                settings = settings.withTypeLevel(type, level),
                          );
                        } on ArgumentError {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.inbox_settingsDecisionMuted),
                            ),
                          );
                        }
                      },
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(l10n.common_cancel),
              ),
              FilledButton(
                onPressed: () {
                  ref
                      .read(gameControllerProvider.notifier)
                      .updateLeague(
                        (league) => league.copyWith(messageSettings: settings),
                      );
                  Navigator.pop(dialogContext);
                },
                child: Text(l10n.common_save),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _settingsRow(
    BuildContext context,
    String title,
    NotificationLevel value,
    ValueChanged<NotificationLevel> onChanged,
  ) {
    return ListTile(
      dense: true,
      title: Text(title),
      trailing: DropdownButton<NotificationLevel>(
        value: value,
        items: [
          for (final level in NotificationLevel.values)
            DropdownMenuItem(
              value: level,
              child: Text(notificationLevelLabel(context, level)),
            ),
        ],
        onChanged: (level) {
          if (level != null) onChanged(level);
        },
      ),
    );
  }

  bool _domainHasDecision(MessageDomain domain) {
    return MessageCatalog.templates.any(
      (template) => template.domain == domain && template.decision != null,
    );
  }
}

class _MessageDetails extends StatelessWidget {
  const _MessageDetails({
    required this.message,
    required this.title,
    required this.body,
    required this.onDecision,
    required this.onAcknowledge,
    required this.onAction,
    required this.digestMembers,
  });

  final GameMessage message;
  final String title;
  final String body;
  final ValueChanged<String> onDecision;
  final VoidCallback onAcknowledge;
  final ValueChanged<MessageAction> onAction;
  final List<(String, String)> digestMembers;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final urgent = message.priority == MessagePriority.urgent;
    final expiry = message.expiresAt == null
        ? null
        : DateTime.tryParse(message.expiresAt!);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (urgent)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.flag,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(body, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 12),
            Text(
              l10n.inbox_metadata(
                message.week,
                message.day,
                messageDomainLabel(context, message.domain),
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (expiry != null) ...[
              const SizedBox(height: 6),
              Text(l10n.inbox_deadline(_formatDate(expiry))),
            ],
            if (message.decision != null) ...[
              const SizedBox(height: 18),
              Text(
                l10n.inbox_decisionOptions,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              for (final option in message.decision!.options)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => onDecision(option.id),
                      child: Text(_decisionLabel(context, option)),
                    ),
                  ),
                ),
              Text(
                l10n.inbox_defaultOnExpiry(
                  _decisionLabelById(
                    context,
                    message,
                    message.decision!.defaultOnExpiry,
                  ),
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (message.actions.isNotEmpty) ...[
              const SizedBox(height: 18),
              Text(
                l10n.inbox_actions,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              for (final action in message.actions)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: OutlinedButton.icon(
                    onPressed: () => onAction(action),
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(_actionLabel(context, action)),
                  ),
                ),
            ],
            if (digestMembers.isNotEmpty) ...[
              const SizedBox(height: 18),
              ExpansionTile(
                title: Text(l10n.inbox_digestMembers(digestMembers.length)),
                children: [
                  for (final member in digestMembers)
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.history),
                      title: Text(member.$1),
                      subtitle: Text(member.$2),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            if (urgent && message.decision == null)
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: onAcknowledge,
                  child: Text(l10n.inbox_acknowledge),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.inbox_close),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _decisionLabel(BuildContext context, MessageAction action) =>
      _actionLabel(context, action);

  String _decisionLabelById(
    BuildContext context,
    GameMessage message,
    String id,
  ) {
    for (final option in message.decision?.options ?? const <MessageAction>[]) {
      if (option.id == id) return _decisionLabel(context, option);
    }
    return id;
  }

  String _actionLabel(BuildContext context, MessageAction action) {
    final l10n = AppLocalizations.of(context)!;
    final id = action.id.toLowerCase();
    if (id.contains('accept') || id == 'finalize')
      return l10n.inbox_actionAccept;
    if (id.contains('decline') || id.contains('reject') || id == 'cancel') {
      return l10n.inbox_actionDecline;
    }
    if (id.contains('counter')) return l10n.inbox_actionCounter;
    if (id.contains('open') || id.contains('watchlist'))
      return l10n.inbox_actionOpen;
    return l10n.inbox_actionFallback;
  }

  static String _formatDate(DateTime value) {
    final local = value.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}
