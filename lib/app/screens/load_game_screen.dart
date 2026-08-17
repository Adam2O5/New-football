import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/app/l10n/enum_labels.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/data/save_repository.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

class LoadGameScreen extends ConsumerWidget {
  const LoadGameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final saves = ref.watch(savesListProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.loadGame_title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: ScreenBackground(
        child: saves.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(l10n.loadGame_error('$e'))),
          data: (list) {
            if (list.isEmpty) {
              return Center(child: Text(l10n.loadGame_empty));
            }
            return Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final meta = list[i];
                  final compatibility = meta.compatibilityWith(
                    SaveRepository.currentSchemaVersion,
                  );
                  final reason = _incompatibilityReason(
                    l10n,
                    meta,
                    compatibility,
                  );
                  return Card(
                    child: ListTile(
                      title: Text(meta.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.loadGame_subtitle(
                              meta.playerTeamName ?? '—',
                              meta.seasonYear,
                              seasonPhaseLabel(context, meta.phase),
                            ),
                          ),
                          if (reason != null)
                            Text(
                              reason,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            tooltip: l10n.loadGame_delete,
                            onPressed: () =>
                                _confirmDeleteSave(context, ref, meta),
                          ),
                          Icon(
                            compatibility == SaveCompatibility.compatible
                                ? Icons.chevron_right
                                : Icons.lock_outline,
                          ),
                        ],
                      ),
                      onTap: compatibility == SaveCompatibility.compatible
                          ? () async {
                              await ref
                                  .read(gameControllerProvider.notifier)
                                  .loadGame(meta.id);
                              if (!context.mounted) return;
                              if (ref.read(gameControllerProvider).hasError) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.loadGame_loadFailed),
                                  ),
                                );
                                return;
                              }
                              context.go('/game');
                            }
                          : null,
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  String? _incompatibilityReason(
    AppLocalizations l10n,
    GameSaveMeta meta,
    SaveCompatibility compatibility,
  ) {
    return switch (compatibility) {
      SaveCompatibility.compatible => null,
      SaveCompatibility.older => l10n.loadGame_incompatibleOlder(
        SaveRepository.currentSchemaVersion,
        meta.schemaVersion,
      ),
      SaveCompatibility.newer => l10n.loadGame_incompatibleNewer(
        SaveRepository.currentSchemaVersion,
        meta.schemaVersion,
      ),
    };
  }

  Future<void> _confirmDeleteSave(
    BuildContext context,
    WidgetRef ref,
    GameSaveMeta meta,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.loadGame_deleteConfirmTitle),
        content: Text(l10n.loadGame_deleteConfirmMessage(meta.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.common_cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.loadGame_delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(saveRepositoryProvider).delete(meta.id);
      final current = ref.read(gameControllerProvider).value;
      if (current?.meta.id == meta.id) {
        ref.read(gameControllerProvider.notifier).clear();
      }
      ref.invalidate(savesListProvider);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.loadGame_deleteFailed)));
    }
  }
}
