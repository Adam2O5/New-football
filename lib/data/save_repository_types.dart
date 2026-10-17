part of 'save_repository.dart';

class SaveRepositoryException implements Exception {
  SaveRepositoryException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() =>
      'SaveRepositoryException: $message${cause != null ? ' ($cause)' : ''}';
}

/// Raised when a transaction could not be reconciled to a verified file pair.
///
/// Callers must not treat this exception as a successful save. The repository
/// leaves its recovery artifacts in place so a later reconciliation can inspect
/// the files instead of deleting the only remaining copy.
class SaveAmbiguousWriteException extends SaveRepositoryException {
  SaveAmbiguousWriteException({required this.saveId, Object? cause})
    : super(
        'Save $saveId has an ambiguous write outcome; reconciliation is '
        'required',
        cause: cause,
      );

  final String saveId;
}

enum SaveRepositoryWriteStage { gameFile, indexFile }

enum SaveRepositoryCheckpoint {
  prepared,
  gameDisplaced,
  indexDisplaced,
  gamePublished,
  indexPublished,
  committed,
}

typedef SaveRepositoryCheckpointHook =
    Future<void> Function(SaveRepositoryCheckpoint checkpoint);

typedef SaveRepositoryPublishHook =
    Future<void> Function(SaveRepositoryWriteStage stage);

class SaveSchemaMismatchException extends SaveRepositoryException {
  SaveSchemaMismatchException({
    required this.foundVersion,
    required this.supportedVersion,
  }) : super(
         'Save schema $foundVersion is not compatible with supported '
         'schema $supportedVersion',
       );

  final int foundVersion;
  final int supportedVersion;

  bool get isOlder => foundVersion < supportedVersion;
  bool get isNewer => foundVersion > supportedVersion;
}

/// Raised when a canonical save file is required but is not present.
///
/// This is intentionally separate from [SaveRepositoryException] instances
/// for malformed serialized data so management callers can report an
/// unavailable source without treating it as a corrupt source.
class SaveFileNotFoundException extends SaveRepositoryException {
  SaveFileNotFoundException({required this.saveId})
    : super('Save file not found: $saveId');

  final String saveId;
}

/// Raised when a canonical save file cannot be parsed or has an invalid raw
/// object shape or identity.
class InvalidSerializedSaveException extends SaveRepositoryException {
  InvalidSerializedSaveException({
    required this.saveId,
    required String reason,
    Object? cause,
  }) : super('Invalid serialized save $saveId: $reason', cause: cause);

  final String saveId;
}

class _CommittedSaveJson {
  const _CommittedSaveJson({required this.gameJson, required this.indexJson});

  final Map<String, dynamic> gameJson;
  final List<dynamic> indexJson;
}

class _PreparedSaveTransaction {
  _PreparedSaveTransaction({
    required this.id,
    required this.saveId,
    required this.gameFile,
    required this.indexFile,
  });

  final String id;
  final String saveId;
  final _PreparedSaveFile gameFile;
  final _PreparedSaveFile indexFile;
  File get journal =>
      File('${indexFile.destination.parent.path}/${_SaveRecovery.journalName}');
  File get commitMarker => File('${journal.path}.commit');
  List<_PreparedSaveFile> get files => [gameFile, indexFile];
}

class _PreparedSaveFile {
  _PreparedSaveFile({
    required this.destination,
    required String transactionId,
    required this.stage,
  }) : temporary = File('${destination.path}.tmp-$transactionId-${stage.name}'),
       backup = File('${destination.path}.bak-$transactionId-${stage.name}'),
       displaced = File('${destination.path}.old-$transactionId-${stage.name}'),
       restoring = File(
         '${destination.path}.restore-$transactionId-${stage.name}',
       );

  final File destination;
  final File temporary;
  final File backup;
  final File displaced;
  final File restoring;
  final SaveRepositoryWriteStage stage;
  _SaveFingerprint? original;
}
