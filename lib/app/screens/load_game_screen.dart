import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/branding/club_asset_registry.dart';
import 'package:new_football/app/branding/club_branding_registry.dart';
import 'package:new_football/app/branding/club_color_tokens.dart';
import 'package:new_football/app/l10n/enum_labels.dart';
import 'package:new_football/app/providers/club_branding_provider.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/providers/save_management_provider.dart';
import 'package:new_football/app/utils/formatters.dart';
import 'package:new_football/app/widgets/branding/club_logo.dart';
import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/app/widgets/team_selection/team_selection_assets.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/save_record.dart';
import 'package:new_football/core/services/save_management_service.dart';
import 'package:new_football/core/services/save_name_policy.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

class LoadGameScreen extends ConsumerStatefulWidget {
  const LoadGameScreen({super.key});

  @override
  ConsumerState<LoadGameScreen> createState() => _LoadGameScreenState();
}

class _LoadGameScreenState extends ConsumerState<LoadGameScreen> {
  final Set<String> _inFlightActions = <String>{};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final saves = ref.watch(saveRecordsProvider);
    final brandingRegistry = ref.watch(clubBrandingProvider);
    final previewTeams = ref.watch(gameFactoryProvider).previewTeams();
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
          error: (error, _) =>
              Center(child: Text(_readErrorMessage(l10n, error))),
          data: (records) {
            if (records.isEmpty) {
              return Center(child: Text(l10n.loadGame_empty));
            }
            final teamIdByName = {
              for (final team in previewTeams) team.name: team.id,
            };
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
                itemCount: records.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  return _buildSaveRow(
                    context,
                    l10n,
                    records[index],
                    records,
                    brandingRegistry,
                    teamIdByName,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSaveRow(
    BuildContext context,
    AppLocalizations l10n,
    SaveRecord record,
    List<SaveRecord> records,
    ClubBrandingRegistry brandingRegistry,
    Map<String, String> teamIdByName,
  ) {
    final meta = record.meta;
    final canLoad = record.compatibility == SaveCompatibility.compatible;
    final canManage = record.serializedFileAvailable;
    final duplicateInFlight = _isActionInFlight(
      meta.id,
      SaveManagementAction.duplicate,
    );
    final renameInFlight = _isActionInFlight(
      meta.id,
      SaveManagementAction.rename,
    );
    final size = record.serializedFileAvailable
        ? formatSaveSize(record.sizeBytes) ?? l10n.loadGame_sizeUnavailable
        : l10n.loadGame_sizeUnavailable;
    final updatedAt = formatSaveDate(
      meta.updatedAt,
      Localizations.localeOf(context).languageCode,
    );
    final compatibilityLabel = _compatibilityLabel(l10n, record.compatibility);
    final incompatibilityReason = _incompatibilityReason(
      l10n,
      meta,
      record.compatibility,
    );
    final showSchemaStatus =
        record.compatibility != SaveCompatibility.compatible;

    final colorScheme = Theme.of(context).colorScheme;
    final teamId = teamIdByName[meta.playerTeamName];
    final branding = teamId == null ? null : brandingRegistry.resolve(teamId);
    final isBranded = branding != null;
    final primaryColor = branding?.primaryColor ?? colorScheme.surface;
    final secondaryColor =
        branding?.secondaryColor ?? colorScheme.outlineVariant;
    final foregroundColor = branding == null
        ? colorScheme.onSurface
        : foregroundFor(primaryColor);
    final logoAsset =
        branding?.logoAsset ?? ClubAssetRegistry.production.fallbackLogoAsset;
    final fallbackLogoAsset = ClubAssetRegistry.production.fallbackLogoAsset;
    final textTheme = Theme.of(context).textTheme;
    final titleStyle = textTheme.titleMedium?.copyWith(
      color: foregroundColor,
      fontWeight: FontWeight.w700,
    );
    final bodyStyle = textTheme.bodyMedium?.copyWith(color: foregroundColor);

    return Card(
      key: ValueKey<String>('save-row-${meta.id}'),
      color: isBranded ? primaryColor : null,
      surfaceTintColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isBranded ? secondaryColor : Colors.transparent,
        ),
      ),
      child: InkWell(
        onTap: canLoad ? () => _loadSave(context, meta.id, l10n) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: Column(
                children: [
                  ClubLogo(
                    assetPath: logoAsset,
                    fallbackAssetPath: fallbackLogoAsset,
                    size: TeamSelectionAssets.iconSize,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    meta.name,
                    textAlign: TextAlign.center,
                    style: titleStyle,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.loadGame_subtitle(
                      meta.playerTeamName ?? '—',
                      meta.seasonYear,
                      seasonPhaseLabel(context, meta.phase),
                    ),
                    textAlign: TextAlign.center,
                    style: bodyStyle,
                  ),
                  Text(
                    '${l10n.loadGame_lastSaveDate}: $updatedAt',
                    textAlign: TextAlign.center,
                    style: bodyStyle,
                  ),
                  Text(
                    '${l10n.loadGame_saveSize}: $size',
                    textAlign: TextAlign.center,
                    style: bodyStyle,
                  ),
                  if (showSchemaStatus)
                    Semantics(
                      key: ValueKey<String>('save-schema-status-${meta.id}'),
                      container: true,
                      excludeSemantics: true,
                      label: compatibilityLabel,
                      child: Text(
                        compatibilityLabel,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _compatibilityColor(
                            context,
                            record.compatibility,
                          ),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (incompatibilityReason != null)
                    Semantics(
                      key: ValueKey<String>('save-schema-reason-${meta.id}'),
                      container: true,
                      excludeSemantics: true,
                      label: incompatibilityReason,
                      child: Text(
                        incompatibilityReason,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: IconTheme(
                  data: IconThemeData(color: foregroundColor),
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      _actionButton(
                        keyValue: 'save-load-${meta.id}',
                        icon: Icons.file_open_outlined,
                        tooltip: l10n.loadGame_loadTooltip,
                        semanticsLabel: l10n.loadGame_loadSemantics(meta.name),
                        onPressed: canLoad
                            ? () => _loadSave(context, meta.id, l10n)
                            : null,
                      ),
                      _actionButton(
                        keyValue: 'save-delete-${meta.id}',
                        icon: Icons.delete_outline,
                        tooltip: l10n.loadGame_deleteTooltip,
                        semanticsLabel: l10n.loadGame_deleteSemantics(
                          meta.name,
                        ),
                        onPressed: () => _confirmDeleteSave(context, record),
                      ),
                      _actionButton(
                        keyValue: 'save-duplicate-${meta.id}',
                        icon: Icons.content_copy_outlined,
                        tooltip: l10n.loadGame_duplicateTooltip,
                        semanticsLabel: l10n.loadGame_duplicateSemantics(
                          meta.name,
                        ),
                        onPressed: canManage && !duplicateInFlight
                            ? () => _duplicateSave(context, record)
                            : null,
                      ),
                      _actionButton(
                        keyValue: 'save-rename-${meta.id}',
                        icon: Icons.edit_outlined,
                        tooltip: l10n.loadGame_renameTooltip,
                        semanticsLabel: l10n.loadGame_renameSemantics(
                          meta.name,
                        ),
                        onPressed: canManage && !renameInFlight
                            ? () => _requestRename(context, record, records)
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (isBranded)
              SizedBox(
                width: double.infinity,
                height: 4,
                child: ColoredBox(color: secondaryColor),
              ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required String keyValue,
    required IconData icon,
    required String tooltip,
    required String semanticsLabel,
    required VoidCallback? onPressed,
  }) {
    return Semantics(
      container: true,
      button: true,
      enabled: onPressed != null,
      label: semanticsLabel,
      onTap: onPressed,
      excludeSemantics: true,
      child: IconButton(
        key: ValueKey<String>(keyValue),
        icon: Icon(icon),
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
  }

  Future<void> _loadSave(
    BuildContext context,
    String saveId,
    AppLocalizations l10n,
  ) async {
    await ref.read(gameControllerProvider.notifier).loadGame(saveId);
    if (!context.mounted) return;
    if (ref.read(gameControllerProvider).hasError) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.loadGame_loadFailed)));
      return;
    }
    context.go('/game');
  }

  Future<void> _confirmDeleteSave(
    BuildContext context,
    SaveRecord record,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.loadGame_deleteConfirmTitle),
        content: Text(l10n.loadGame_deleteConfirmMessage(record.meta.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.common_cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.loadGame_delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(saveManagementCoordinatorProvider).delete(record.meta.id);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.loadGame_deleteFailed)));
    }
  }

  Future<void> _duplicateSave(BuildContext context, SaveRecord record) async {
    final actionKey = _actionKey(
      record.meta.id,
      SaveManagementAction.duplicate,
    );
    if (_isActionInFlight(record.meta.id, SaveManagementAction.duplicate)) {
      return;
    }
    setState(() => _inFlightActions.add(actionKey));

    final l10n = AppLocalizations.of(context)!;
    try {
      final result = await ref
          .read(saveManagementCoordinatorProvider)
          .duplicate(record.meta.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.loadGame_duplicateSuccess(result.meta.name)),
        ),
      );
    } on SaveManagementException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_duplicateErrorMessage(l10n, error))),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.loadGame_duplicateFailed)));
    } finally {
      if (mounted) {
        setState(() => _inFlightActions.remove(actionKey));
      }
    }
  }

  Future<void> _requestRename(
    BuildContext context,
    SaveRecord record,
    List<SaveRecord> records,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: record.meta.name);

    try {
      final result = await showDialog<SaveManagementResult>(
        context: context,
        builder: (dialogContext) {
          String? validationError;
          var submitting = false;

          return StatefulBuilder(
            builder: (dialogContext, setDialogState) {
              Future<void> submit() async {
                if (submitting) return;

                final localValidationError = _renameValidationMessage(
                  l10n: l10n,
                  record: record,
                  records: records,
                  proposedName: controller.text,
                );
                if (localValidationError != null) {
                  setDialogState(() => validationError = localValidationError);
                  return;
                }

                setDialogState(() => submitting = true);
                try {
                  final result = await _renameSave(record, controller.text);
                  if (!dialogContext.mounted) return;
                  Navigator.of(dialogContext).pop(result);
                } on SaveManagementException catch (error) {
                  if (!dialogContext.mounted) return;
                  if (_isRenameValidationFailure(error.code)) {
                    setDialogState(() {
                      validationError = _renameErrorMessage(l10n, error);
                      submitting = false;
                    });
                    return;
                  }

                  Navigator.of(dialogContext).pop();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(_renameErrorMessage(l10n, error))),
                    );
                  }
                } catch (_) {
                  if (!dialogContext.mounted) return;
                  Navigator.of(dialogContext).pop();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.loadGame_renameFailed)),
                    );
                  }
                } finally {
                  if (dialogContext.mounted && submitting) {
                    setDialogState(() => submitting = false);
                  }
                }
              }

              return AlertDialog(
                key: ValueKey<String>('rename-dialog-${record.meta.id}'),
                title: Text(l10n.loadGame_renameTitle),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.loadGame_renameMessage(record.meta.name)),
                    const SizedBox(height: 16),
                    TextField(
                      key: ValueKey<String>(
                        'save-rename-field-${record.meta.id}',
                      ),
                      controller: controller,
                      autofocus: true,
                      enabled: !submitting,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => submit(),
                      onChanged: (_) {
                        if (validationError != null) {
                          setDialogState(() => validationError = null);
                        }
                      },
                      decoration: InputDecoration(
                        labelText: l10n.loadGame_renameLabel,
                        hintText: l10n.loadGame_renameHint,
                        errorText: validationError,
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: submitting
                        ? null
                        : () => Navigator.of(dialogContext).pop(),
                    child: Text(l10n.common_cancel),
                  ),
                  TextButton(
                    key: ValueKey<String>(
                      'save-rename-confirm-${record.meta.id}',
                    ),
                    onPressed: submitting ? null : submit,
                    child: Text(l10n.loadGame_renameConfirm),
                  ),
                ],
              );
            },
          );
        },
      );

      if (!context.mounted || result == null) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.loadGame_renameSuccess(result.meta.name))),
      );
    } finally {
      // showDialog completes when pop starts the reverse transition. Keep the
      // controller alive until that transition has left the TextField tree.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      controller.dispose();
    }
  }

  Future<SaveManagementResult> _renameSave(
    SaveRecord record,
    String proposedName,
  ) async {
    final actionKey = _actionKey(record.meta.id, SaveManagementAction.rename);
    if (_inFlightActions.contains(actionKey)) {
      throw const SaveManagementException(SaveManagementFailure.writeFailed);
    }
    setState(() => _inFlightActions.add(actionKey));

    try {
      return await ref
          .read(saveManagementCoordinatorProvider)
          .rename(record.meta.id, proposedName);
    } finally {
      if (mounted) {
        setState(() => _inFlightActions.remove(actionKey));
      }
    }
  }

  String? _renameValidationMessage({
    required AppLocalizations l10n,
    required SaveRecord record,
    required List<SaveRecord> records,
    required String proposedName,
  }) {
    final trimmedName = SaveNamePolicy.trimName(proposedName);
    if (trimmedName.isEmpty) return l10n.loadGame_nameEmpty;

    try {
      final candidateKey = SaveNamePolicy.nameKey(trimmedName);
      if (candidateKey == SaveNamePolicy.nameKey(record.meta.name)) {
        return l10n.loadGame_nameSame;
      }

      final nameTaken = records.any((candidate) {
        if (candidate.meta.id == record.meta.id) return false;
        try {
          return SaveNamePolicy.nameKey(candidate.meta.name) == candidateKey;
        } on ArgumentError {
          return false;
        }
      });
      return nameTaken ? l10n.loadGame_nameTaken : null;
    } on ArgumentError {
      // The service remains the final authority for malformed persisted
      // metadata; let it return its typed domain failure.
      return null;
    }
  }

  bool _isRenameValidationFailure(SaveManagementFailure failure) {
    return switch (failure) {
      SaveManagementFailure.emptyName ||
      SaveManagementFailure.sameName ||
      SaveManagementFailure.nameTaken => true,
      _ => false,
    };
  }

  String _renameErrorMessage(
    AppLocalizations l10n,
    SaveManagementException error,
  ) {
    return switch (error.code) {
      SaveManagementFailure.emptyName => l10n.loadGame_nameEmpty,
      SaveManagementFailure.sameName => l10n.loadGame_nameSame,
      SaveManagementFailure.nameTaken => l10n.loadGame_nameTaken,
      SaveManagementFailure.sourceUnavailable =>
        l10n.loadGame_sourceUnavailable,
      SaveManagementFailure.invalidSerializedSave =>
        l10n.loadGame_invalidSerializedSave,
      SaveManagementFailure.indexReadFailed => l10n.loadGame_indexReadFailed,
      SaveManagementFailure.writeFailed => l10n.loadGame_writeFailed,
      SaveManagementFailure.ambiguousWrite => l10n.loadGame_ambiguousWrite,
    };
  }

  bool _isActionInFlight(String saveId, SaveManagementAction action) {
    return _inFlightActions.contains(_actionKey(saveId, action)) ||
        ref
            .read(saveManagementCoordinatorProvider)
            .isActionInFlight(saveId, action);
  }

  String _actionKey(String saveId, SaveManagementAction action) {
    return '$saveId:${action.name}';
  }

  String _readErrorMessage(AppLocalizations l10n, Object error) {
    if (error is SaveManagementException &&
        error.code == SaveManagementFailure.indexReadFailed) {
      return l10n.loadGame_indexReadFailed;
    }
    return l10n.loadGame_readFailed;
  }

  String _duplicateErrorMessage(
    AppLocalizations l10n,
    SaveManagementException error,
  ) {
    return switch (error.code) {
      SaveManagementFailure.sourceUnavailable =>
        l10n.loadGame_sourceUnavailable,
      SaveManagementFailure.invalidSerializedSave =>
        l10n.loadGame_invalidSerializedSave,
      SaveManagementFailure.ambiguousWrite => l10n.loadGame_ambiguousWrite,
      SaveManagementFailure.indexReadFailed => l10n.loadGame_indexReadFailed,
      SaveManagementFailure.writeFailed => l10n.loadGame_writeFailed,
      _ => l10n.loadGame_duplicateFailed,
    };
  }

  String _compatibilityLabel(
    AppLocalizations l10n,
    SaveCompatibility compatibility,
  ) {
    return switch (compatibility) {
      SaveCompatibility.compatible => l10n.loadGame_schemaCompatible,
      SaveCompatibility.older => l10n.loadGame_schemaOlder,
      SaveCompatibility.newer => l10n.loadGame_schemaNewer,
    };
  }

  Color _compatibilityColor(
    BuildContext context,
    SaveCompatibility compatibility,
  ) {
    final colors = Theme.of(context).colorScheme;
    return switch (compatibility) {
      SaveCompatibility.compatible => colors.primary,
      SaveCompatibility.older || SaveCompatibility.newer => colors.error,
    };
  }

  String? _incompatibilityReason(
    AppLocalizations l10n,
    GameSaveMeta meta,
    SaveCompatibility compatibility,
  ) {
    return switch (compatibility) {
      SaveCompatibility.compatible => null,
      SaveCompatibility.older => l10n.loadGame_incompatibleOlder(
        SaveSchema.currentVersion,
        meta.schemaVersion,
      ),
      SaveCompatibility.newer => l10n.loadGame_incompatibleNewer(
        SaveSchema.currentVersion,
        meta.schemaVersion,
      ),
    };
  }
}
