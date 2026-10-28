part of 'game_provider.dart';

/// Distinguishes a failed durable save from a command which was not applied.
class MessageConfirmationSaveException implements Exception {
  const MessageConfirmationSaveException(this.cause);

  final Object cause;
}

/// One confirmation bound to the career which opened its message details.
/// A save retry never repeats the already-applied domain command.
class MessageConfirmation {
  MessageConfirmation._({
    required bool Function() isCurrent,
    required Future<void> Function() acknowledge,
    required Future<void> Function(String) decide,
    required Future<void> Function() flush,
    required Future<void> Function() persist,
  }) : _isCurrent = isCurrent,
       _acknowledge = acknowledge,
       _decide = decide,
       _flush = flush,
       _persist = persist;

  final bool Function() _isCurrent;
  final Future<void> Function() _acknowledge;
  final Future<void> Function(String) _decide;
  final Future<void> Function() _flush;
  final Future<void> Function() _persist;
  Future<void> Function()? _command;
  Future<void>? _inFlight;
  bool _applied = false;
  bool _saved = false;

  bool get isCurrent => _isCurrent();

  Future<void> acknowledge() => _run(_acknowledge);

  Future<void> decide(String optionId) => _run(() => _decide(optionId));

  Future<void> _run(Future<void> Function() command) {
    final pending = _inFlight;
    if (pending != null) return pending;
    _command ??= command;
    late final Future<void> attempt;
    attempt = _attempt().whenComplete(() {
      if (identical(_inFlight, attempt)) _inFlight = null;
    });
    _inFlight = attempt;
    return attempt;
  }

  Future<void> _attempt() async {
    if (!isCurrent || _saved) return;
    final retrySave = _applied;
    if (!_applied) {
      await _command!();
      _applied = true;
    }
    try {
      if (retrySave) {
        await _persist();
      } else {
        await _flush();
      }
      _saved = true;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        MessageConfirmationSaveException(error),
        stackTrace,
      );
    }
  }
}
