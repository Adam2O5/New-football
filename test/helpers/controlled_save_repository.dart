import 'dart:async';
import 'dart:io';

import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/data/save_repository.dart';

enum ControlledSaveFailure { none, beforeWrite, afterPartialWrite }

/// Failure points for raw save-management transactions.
///
/// The production repository publishes the game file before the index. The
/// two publication-related values therefore both fail from the hook invoked
/// immediately before the index is published, while [beforeWrite] fails from
/// the game-file publication hook before either destination is changed.
enum ControlledManagementFailure {
  none,
  beforeWrite,
  afterGameFilePublication,
  beforeIndexPublication,
}

/// Deterministic repository double for delayed and failed persistence flows.
///
/// [afterPartialWrite] lets the production transaction publish the game file,
/// fail before publishing the index, and exercise its rollback path. The
/// optional management controls use the same existing repository publication
/// hook, so they also apply to future [SaveRepository.duplicateRaw] and
/// [SaveRepository.renameRaw] transactions without changing [save]'s legacy
/// behavior.
class ControlledSaveRepository extends SaveRepository {
  factory ControlledSaveRepository({
    Directory? overrideDirectory,
    Duration delay = Duration.zero,
    bool waitForRelease = false,
    ControlledSaveFailure failure = ControlledSaveFailure.none,
    Duration? managementDelay,
    bool? waitForManagementRelease,
    ControlledManagementFailure? managementFailure,
  }) {
    final control = _ControlledSaveControl(
      delay: delay,
      waitForRelease: waitForRelease,
      failure: failure,
      // Falling back to the existing controls keeps the helper convenient for
      // management tests while preserving the old save-only constructor API.
      managementDelay: managementDelay ?? delay,
      waitForManagementRelease:
          waitForManagementRelease ?? waitForRelease,
      managementFailureOverride: managementFailure,
    );
    return ControlledSaveRepository._(
      control,
      overrideDirectory: overrideDirectory,
    );
  }

  ControlledSaveRepository._(
    _ControlledSaveControl control, {
    super.overrideDirectory,
  }) : _control = control,
       super(beforePublish: control.beforePublish);

  final _ControlledSaveControl _control;

  int saveCount = 0;
  int activeSaveCount = 0;
  int maxConcurrentSaves = 0;
  final attemptedSaves = <GameSave>[];
  final completedSaves = <GameSave>[];
  final saveStarted = <GameSave>[];

  /// Counts management transactions once they reach the game-file
  /// publication boundary. This is deliberately separate from [saveCount] so
  /// queue tests can assert that management writes never overlap each other.
  int get managementOperationCount => _control.managementOperationCount;
  int get activeManagementOperationCount =>
      _control.activeManagementOperationCount;
  int get maxConcurrentManagementOperations =>
      _control.maxConcurrentManagementOperations;

  /// Alias using the terminology used by transaction tests.
  int get activeManagementWriteCount => activeManagementOperationCount;
  int get maxConcurrentManagementWrites => maxConcurrentManagementOperations;

  /// Completes when a management transaction reaches the controlled
  /// publication hook. Tests can await this instead of guessing how many
  /// microtasks to flush.
  Future<void> get firstManagementOperationStarted =>
      _control.firstManagementOperationStarted.future;

  /// Completes when the first save reaches the controlled repository. Tests
  /// can await this instead of guessing how many microtasks to flush.
  Future<void> get firstSaveStarted => _control.firstSaveStarted.future;

  Duration get delay => _control.delay;
  bool get waitForRelease => _control.waitForRelease;
  ControlledSaveFailure get failure => _control.failure;
  set failure(ControlledSaveFailure value) => _control.failure = value;

  Duration get managementDelay => _control.managementDelay;
  bool get waitForManagementRelease =>
      _control.waitForManagementRelease;
  ControlledManagementFailure get managementFailure =>
      _control.managementFailure;
  set managementFailure(ControlledManagementFailure value) =>
      _control.managementFailure = value;

  GameSave? get lastPersisted =>
      completedSaves.isEmpty ? null : completedSaves.last;

  @override
  Future<void> save(GameSave gameSave) async {
    saveCount++;
    attemptedSaves.add(gameSave);
    saveStarted.add(gameSave);
    if (!_control.firstSaveStarted.isCompleted) {
      _control.firstSaveStarted.complete();
    }
    activeSaveCount++;
    _control.enterSave();
    if (activeSaveCount > maxConcurrentSaves) {
      maxConcurrentSaves = activeSaveCount;
    }
    try {
      if (delay > Duration.zero) await Future<void>.delayed(delay);
      if (waitForRelease) await _control.releaseCompleter.future;

      if (failure == ControlledSaveFailure.beforeWrite) {
        throw SaveRepositoryException('Controlled failure before write');
      }

      await super.save(gameSave);
      completedSaves.add(gameSave);
    } finally {
      _control.leaveSave();
      activeSaveCount--;
    }
  }

  /// Releases both the legacy save gate and the management-operation gate.
  ///
  /// Keeping this method's original behavior means existing save tests do not
  /// need to change when the helper is used for management transactions.
  void release() {
    releaseSave();
    releaseManagement();
  }

  void releaseSave() {
    if (!_control.releaseCompleter.isCompleted) {
      _control.releaseCompleter.complete();
    }
  }

  void releaseManagement() {
    if (!_control.managementReleaseCompleter.isCompleted) {
      _control.managementReleaseCompleter.complete();
    }
  }
}

class _ControlledSaveControl {
  _ControlledSaveControl({
    required this.delay,
    required this.waitForRelease,
    required this.failure,
    required this.managementDelay,
    required this.waitForManagementRelease,
    required ControlledManagementFailure? managementFailureOverride,
  }) : _managementFailureOverride = managementFailureOverride;

  final Duration delay;
  final bool waitForRelease;
  final Completer<void> releaseCompleter = Completer<void>();
  final Completer<void> firstSaveStarted = Completer<void>();
  ControlledSaveFailure failure;

  final Duration managementDelay;
  final bool waitForManagementRelease;
  final Completer<void> managementReleaseCompleter = Completer<void>();
  final Completer<void> firstManagementOperationStarted = Completer<void>();
  ControlledManagementFailure? _managementFailureOverride;

  int _activeSaveTransactions = 0;
  int managementOperationCount = 0;
  int activeManagementOperationCount = 0;
  int maxConcurrentManagementOperations = 0;

  ControlledManagementFailure get managementFailure =>
      _managementFailureOverride ?? _legacyManagementFailure;
  set managementFailure(ControlledManagementFailure value) {
    _managementFailureOverride = value;
  }

  ControlledManagementFailure get _legacyManagementFailure {
    switch (failure) {
      case ControlledSaveFailure.none:
        return ControlledManagementFailure.none;
      case ControlledSaveFailure.beforeWrite:
        return ControlledManagementFailure.beforeWrite;
      case ControlledSaveFailure.afterPartialWrite:
        return ControlledManagementFailure.beforeIndexPublication;
    }
  }

  void enterSave() => _activeSaveTransactions++;

  void leaveSave() {
    if (_activeSaveTransactions > 0) _activeSaveTransactions--;
  }

  Future<void> beforePublish(SaveRepositoryWriteStage stage) async {
    // The legacy save path keeps its exact failure semantics. In particular,
    // beforeWrite is raised by save() before it writes temporary files, and
    // afterPartialWrite is raised at the index publication boundary.
    if (_activeSaveTransactions > 0) {
      if (failure == ControlledSaveFailure.afterPartialWrite &&
          stage == SaveRepositoryWriteStage.indexFile) {
        throw SaveRepositoryException(
          'Controlled failure after game file publication',
        );
      }
      return;
    }

    // Raw duplicate/rename transactions use the same repository hook. The
    // game-file callback is before the first destination publication and is
    // therefore the deterministic pre-write failure/gate boundary.
    if (stage == SaveRepositoryWriteStage.gameFile) {
      _startManagementOperation();
      try {
        if (managementFailure == ControlledManagementFailure.beforeWrite) {
          throw SaveRepositoryException(
            'Controlled management failure before write',
          );
        }
        if (managementDelay > Duration.zero) {
          await Future<void>.delayed(managementDelay);
        }
        if (waitForManagementRelease) {
          await managementReleaseCompleter.future;
        }
      } catch (_) {
        _finishManagementOperation();
        rethrow;
      }
      return;
    }

    if (stage == SaveRepositoryWriteStage.indexFile) {
      try {
        if (managementFailure ==
                ControlledManagementFailure.afterGameFilePublication ||
            managementFailure ==
                ControlledManagementFailure.beforeIndexPublication) {
          throw SaveRepositoryException(
            'Controlled management failure before index publication',
          );
        }
      } finally {
        // There is no post-commit hook in the existing repository API. The
        // index publication boundary is the last write hook, so close the
        // observable write window here; repository verification still follows
        // it before the caller receives success.
        _finishManagementOperation();
      }
    }
  }

  void _startManagementOperation() {
    managementOperationCount++;
    activeManagementOperationCount++;
    if (activeManagementOperationCount > maxConcurrentManagementOperations) {
      maxConcurrentManagementOperations = activeManagementOperationCount;
    }
    if (!firstManagementOperationStarted.isCompleted) {
      firstManagementOperationStarted.complete();
    }
  }

  void _finishManagementOperation() {
    if (activeManagementOperationCount > 0) {
      activeManagementOperationCount--;
    }
  }
}
