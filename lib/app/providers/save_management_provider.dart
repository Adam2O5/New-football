import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/providers/settings_provider.dart';
import 'package:new_football/core/models/save_record.dart';
import 'package:new_football/core/services/save_management_service.dart';

/// Domain service used by the save-management list and coordinator.
///
/// The repository is injected through [saveRepositoryProvider] so tests and
/// other application environments can replace persistence without bypassing
/// the provider graph.
final saveManagementServiceProvider = Provider<SaveManagementService>((ref) {
  return SaveManagementService(repository: ref.watch(saveRepositoryProvider));
});

/// The index-backed, runtime-enriched save list consumed by the UI.
///
/// [SaveManagementService.listRecords] remains the only place that decides
/// how to inspect canonical save files and project compatibility.
final saveRecordsProvider = FutureProvider.autoDispose<List<SaveRecord>>((ref) {
  return ref.watch(saveManagementServiceProvider).listRecords();
});

/// The kind of save-management action currently being attempted for a row.
///
/// This is application state rather than a domain concern. It lets a future
/// screen query the coordinator's gate without introducing another operation
/// queue; serialization still belongs exclusively to [GameController].
enum SaveManagementAction { duplicate, rename }

final class _SaveManagementActionKey {
  const _SaveManagementActionKey(this.saveId, this.action);

  final String saveId;
  final SaveManagementAction action;

  @override
  bool operator ==(Object other) {
    return other is _SaveManagementActionKey &&
        other.saveId == saveId &&
        other.action == action;
  }

  @override
  int get hashCode => Object.hash(saveId, action);
}

/// Coordinates save-management actions with the controller's mutation queue.
///
/// The coordinator deliberately does not own a queue. Its in-flight map is
/// only an action gate for presentation code; all repository work is still
/// appended to [GameController.enqueueSaveManagement].
class SaveManagementCoordinator {
  SaveManagementCoordinator(this._ref);

  final Ref _ref;
  final Map<_SaveManagementActionKey, int> _inFlightActions = {};

  /// Whether [action] for [saveId] is currently waiting in or executing from
  /// the shared controller queue.
  bool isActionInFlight(String saveId, SaveManagementAction action) {
    return (_inFlightActions[_SaveManagementActionKey(saveId, action)] ?? 0) >
        0;
  }

  /// Duplicates [sourceId] using the locale captured when this method is
  /// invoked, not when the queued operation eventually starts.
  Future<SaveManagementResult> duplicate(String sourceId) {
    final localeCode = _ref.read(localeProvider).languageCode;
    return _runGated(
      _SaveManagementActionKey(sourceId, SaveManagementAction.duplicate),
      () {
        final controller = _ref.read(gameControllerProvider.notifier);
        return controller.enqueueSaveManagement(() async {
          final result = await _ref
              .read(saveManagementServiceProvider)
              .duplicate(sourceId, localeCode: localeCode);
          _invalidateSaveLists();
          return result;
        });
      },
    );
  }

  /// Renames [saveId] and synchronizes the active in-memory metadata when the
  /// renamed ID is the active save. The synchronization is performed inside
  /// the same queued operation as the repository transaction.
  Future<SaveManagementResult> rename(String saveId, String proposedName) {
    return _runGated(
      _SaveManagementActionKey(saveId, SaveManagementAction.rename),
      () {
        final controller = _ref.read(gameControllerProvider.notifier);
        return controller.enqueueSaveManagement(() async {
          final result = await _ref
              .read(saveManagementServiceProvider)
              .rename(saveId, proposedName);
          controller.applyManagedMeta(saveId, result.meta);
          _invalidateSaveLists();
          return result;
        });
      },
    );
  }

  /// Deletes [saveId] through the same mutation queue as save-management
  /// operations and clears the active save when the deleted ID is loaded.
  Future<void> delete(String saveId) {
    final controller = _ref.read(gameControllerProvider.notifier);
    return controller.enqueueSaveManagement(() async {
      await _ref.read(saveRepositoryProvider).delete(saveId);
      final current = _ref.read(gameControllerProvider).value;
      if (current?.meta.id == saveId) {
        controller.clear();
      }
      _invalidateSaveLists();
    });
  }

  Future<T> _runGated<T>(
    _SaveManagementActionKey key,
    Future<T> Function() operation,
  ) async {
    _inFlightActions[key] = (_inFlightActions[key] ?? 0) + 1;
    try {
      return await operation();
    } finally {
      final count = _inFlightActions[key] ?? 0;
      if (count <= 1) {
        _inFlightActions.remove(key);
      } else {
        _inFlightActions[key] = count - 1;
      }
    }
  }

  void _invalidateSaveLists() {
    _ref.invalidate(saveRecordsProvider);
    // Keep the pre-management provider fresh for consumers that still use
    // the legacy GameSaveMeta-only contract.
    _ref.invalidate(savesListProvider);
  }
}

/// Provider used by screens to obtain the application coordinator.
final saveManagementCoordinatorProvider = Provider<SaveManagementCoordinator>((
  ref,
) {
  return SaveManagementCoordinator(ref);
});
