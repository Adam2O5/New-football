part of 'game_provider.dart';

enum _MessageOperationKind { markRead, acknowledge, decision }

class _MessageOperationKey {
  const _MessageOperationKey(this.messageId, this.kind);

  final String messageId;
  final _MessageOperationKind kind;

  @override
  bool operator ==(Object other) =>
      other is _MessageOperationKey &&
      other.messageId == messageId &&
      other.kind == kind;

  @override
  int get hashCode => Object.hash(messageId, kind);
}

mixin _GameControllerMessages {
  Ref get _ref;

  PlayerEventService get _playerEvents;

  TeamEventService get _teamEvents;

  int get _saveGeneration;

  Future<void>? get _careerTransition;

  Map<_MessageOperationKey, Future<void>> get _inFlightMessageOperations;

  GameSave? get save;

  Future<T> _enqueueMutation<T>(Future<T> Function() operation);

  Future<void> _updateLeagueInQueue(
    LeagueState Function(LeagueState) transform, {
    required int generation,
    bool skipIfUnchanged = false,
  });

  Future<void> _runMessageOperation(
    String messageId,
    _MessageOperationKind kind,
    Future<void> Function() operation,
  ) {
    if (_careerTransition != null) return Future<void>.value();
    final key = _MessageOperationKey(messageId, kind);
    final existing = _inFlightMessageOperations[key];
    if (existing != null) return existing;

    final future = _enqueueMutation(operation);
    _inFlightMessageOperations[key] = future;
    future.then<void>(
      (_) => _removeMessageOperation(key, future),
      onError: (Object error, StackTrace stackTrace) {
        _removeMessageOperation(key, future);
      },
    );
    return future;
  }

  void _removeMessageOperation(
    _MessageOperationKey key,
    Future<void> operation,
  ) {
    if (identical(_inFlightMessageOperations[key], operation)) {
      _inFlightMessageOperations.remove(key);
    }
  }

  GameMessage? _messageById(LeagueState league, String id) {
    for (final message in league.inbox.messages) {
      if (message.id == id) return message;
    }
    return null;
  }

  /// Marks a message as read without acknowledging an urgent pause.
  Future<void> markMessageRead(String id) {
    final generation = _saveGeneration;
    return _runMessageOperation(
      id,
      _MessageOperationKind.markRead,
      () => _updateLeagueInQueue(
        (league) {
          final message = _messageById(league, id);
          if (message == null || message.read) return league;
          return league.copyWith(inbox: league.inbox.markRead(id));
        },
        generation: generation,
        skipIfUnchanged: true,
      ),
    );
  }

  /// Acknowledges an urgent message and releases its simulation pause.
  Future<void> acknowledgeMessage(String id) {
    final generation = _saveGeneration;
    return _runMessageOperation(
      id,
      _MessageOperationKind.acknowledge,
      () => _updateLeagueInQueue(
        (league) {
          final message = _messageById(league, id);
          if (message == null || message.acknowledged) return league;
          return league.copyWith(inbox: league.inbox.acknowledge(id));
        },
        generation: generation,
        skipIfUnchanged: true,
      ),
    );
  }

  /// Applies a decision effect, then acknowledges the message.
  ///
  /// The optional dispatcher is deliberately injected by the caller because
  /// message effects belong to their owning domain service. Without one, the
  /// choice is still recorded and the urgent pause is released safely.
  Future<void> resolveMessageDecision(
    String id,
    String optionId, {
    MessageDecisionHandler? onDecision,
  }) {
    final generation = _saveGeneration;
    return _runMessageOperation(
      id,
      _MessageOperationKind.decision,
      () => _updateLeagueInQueue(
        (league) {
          final message = _messageById(league, id);
          if (message == null || message.acknowledged) return league;
          final decision = message.decision;
          if (decision == null ||
              !decision.options.any((option) => option.id == optionId)) {
            return league;
          }

          // The seed and dispatcher are resolved while the queued snapshot is
          // active. A concurrent mutation therefore cannot make this
          // operation dispatch against a stale save.
          final saveSeed = save?.saveSeed ?? 0;
          final dispatcher =
              onDecision ?? _defaultMessageDecisionDispatcher(saveSeed);
          return MessageService().resolveDecision(
            league,
            id,
            optionId,
            onDecision: dispatcher,
          );
        },
        generation: generation,
        skipIfUnchanged: true,
      ),
    );
  }

  MessageDecisionHandler _defaultMessageDecisionDispatcher(int saveSeed) {
    return (LeagueState league, GameMessage message, String option) {
      if (message.type == MessageType.teamEvent) {
        return _teamEvents.resolveDecision(
          league,
          message,
          option,
          saveSeed: saveSeed,
        );
      }
      if (message.type == MessageType.tradeOffer ||
          (message.type == MessageType.trade && message.kind == 'counter')) {
        final offerId = message.payload['tradeOfferId']?.toString();
        final actingTeamId = league.playerTeamId;
        if (offerId == null || actingTeamId == null) return league;
        final draftService = _ref.read(draftTradeServiceProvider);
        final service = _ref.read(tradeServiceProvider);
        final result = switch (option) {
          'accept' =>
            draftService.isDraftOffer(league, offerId)
                ? draftService.acceptOffer(
                    league,
                    offerId,
                    actingTeamId: actingTeamId,
                  )
                : service.acceptOffer(
                    league,
                    offerId,
                    actingTeamId: actingTeamId,
                  ),
          'reject' =>
            draftService.isDraftOffer(league, offerId)
                ? draftService.rejectOffer(
                    league,
                    offerId,
                    actingTeamId: actingTeamId,
                  )
                : service.rejectOffer(
                    league,
                    offerId,
                    actingTeamId: actingTeamId,
                  ),
          _ => null,
        };
        return result?.league ?? league;
      }
      return _playerEvents.resolveDecision(
        league,
        message,
        option,
        saveSeed: saveSeed,
      );
    };
  }
}
