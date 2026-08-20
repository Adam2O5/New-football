import 'dart:async';
import 'dart:io';

import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/data/save_repository.dart';

enum ControlledSaveFailure { none, beforeWrite, afterPartialWrite }

/// Deterministic repository double for delayed and failed persistence flows.
///
/// [afterPartialWrite] lets the production transaction publish the game file,
/// fail before publishing the index, and exercise its rollback path.
class ControlledSaveRepository extends SaveRepository {
  factory ControlledSaveRepository({
    Directory? overrideDirectory,
    Duration delay = Duration.zero,
    bool waitForRelease = false,
    ControlledSaveFailure failure = ControlledSaveFailure.none,
  }) {
    final control = _ControlledSaveControl(
      delay: delay,
      waitForRelease: waitForRelease,
      failure: failure,
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

  /// Completes when the first save reaches the controlled repository. Tests
  /// can await this instead of guessing how many microtasks to flush.
  Future<void> get firstSaveStarted => _control.firstSaveStarted.future;

  Duration get delay => _control.delay;
  bool get waitForRelease => _control.waitForRelease;
  ControlledSaveFailure get failure => _control.failure;
  set failure(ControlledSaveFailure value) => _control.failure = value;

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
      activeSaveCount--;
    }
  }

  void release() {
    if (!_control.releaseCompleter.isCompleted) {
      _control.releaseCompleter.complete();
    }
  }
}

class _ControlledSaveControl {
  _ControlledSaveControl({
    required this.delay,
    required this.waitForRelease,
    required this.failure,
  });

  final Duration delay;
  final bool waitForRelease;
  final Completer<void> releaseCompleter = Completer<void>();
  final Completer<void> firstSaveStarted = Completer<void>();
  ControlledSaveFailure failure;

  Future<void> beforePublish(SaveRepositoryWriteStage stage) async {
    if (failure == ControlledSaveFailure.afterPartialWrite &&
        stage == SaveRepositoryWriteStage.indexFile) {
      throw SaveRepositoryException(
        'Controlled failure after game file publication',
      );
    }
  }
}
