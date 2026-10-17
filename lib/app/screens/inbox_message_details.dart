part of 'inbox_screen.dart';

enum _MessageDetailsPhase { idle, loading, success, error }

enum _MessageDetailsOperationKind { acknowledge, decision, action }

class _MessageDetails extends StatefulWidget {
  const _MessageDetails({
    required this.message,
    required this.title,
    required this.body,
    required this.onDecision,
    required this.onAcknowledge,
    required this.onAction,
    required this.onCloseSheet,
    required this.digestMembers,
  });

  final GameMessage message;
  final String title;
  final String body;
  final Future<void> Function(String optionId) onDecision;
  final Future<void> Function() onAcknowledge;
  final Future<void> Function(MessageAction action) onAction;
  final VoidCallback onCloseSheet;
  final List<(String, String)> digestMembers;

  @override
  State<_MessageDetails> createState() => _MessageDetailsState();
}

class _MessageDetailsState extends State<_MessageDetails> {
  _MessageDetailsPhase _phase = _MessageDetailsPhase.idle;
  _MessageDetailsOperationKind? _operationKind;
  String? _operationMessageId;
  Object? _error;
  Future<void> Function()? _retryOperation;
  _MessageDetailsOperationKind? _retryKind;
  int _attemptToken = 0;

  bool get _controlsEnabled => _phase == _MessageDetailsPhase.idle;
  bool get _closeEnabled => _phase != _MessageDetailsPhase.loading;

  Future<void> _submit({
    required _MessageDetailsOperationKind kind,
    required Future<void> Function() operation,
    required bool closeOnSuccess,
  }) async {
    if (_phase == _MessageDetailsPhase.loading ||
        _phase == _MessageDetailsPhase.success) {
      return;
    }

    final attemptToken = ++_attemptToken;
    _operationKind = kind;
    _operationMessageId = widget.message.id;
    _retryOperation = null;
    _retryKind = null;
    setState(() {
      _phase = _MessageDetailsPhase.loading;
      _error = null;
    });

    try {
      await operation();
      if (!mounted || !context.mounted || attemptToken != _attemptToken) {
        return;
      }
      if (closeOnSuccess) {
        setState(() => _phase = _MessageDetailsPhase.success);
        if (mounted && context.mounted && attemptToken == _attemptToken) {
          widget.onCloseSheet();
        }
      } else {
        setState(() {
          _phase = _MessageDetailsPhase.idle;
          _operationKind = null;
          _operationMessageId = null;
        });
      }
    } catch (error) {
      if (!mounted || !context.mounted || attemptToken != _attemptToken) {
        return;
      }
      setState(() {
        _phase = _MessageDetailsPhase.error;
        _error = error;
        _retryOperation = operation;
        _retryKind = kind;
      });
    }
  }

  void _retry() {
    if (_phase != _MessageDetailsPhase.error) return;
    final operation = _retryOperation;
    final kind = _retryKind;
    if (operation == null ||
        kind == null ||
        _operationKind != kind ||
        _operationMessageId != widget.message.id) {
      return;
    }
    _submit(
      kind: kind,
      operation: operation,
      closeOnSuccess: kind != _MessageDetailsOperationKind.action,
    );
  }

  void _submitDecision(String optionId) {
    if (!_controlsEnabled) return;
    _submit(
      kind: _MessageDetailsOperationKind.decision,
      operation: () => widget.onDecision(optionId),
      closeOnSuccess: true,
    );
  }

  void _submitAcknowledge() {
    if (!_controlsEnabled) return;
    _submit(
      kind: _MessageDetailsOperationKind.acknowledge,
      operation: widget.onAcknowledge,
      closeOnSuccess: true,
    );
  }

  void _submitAction(MessageAction action) {
    if (!_controlsEnabled) return;
    _submit(
      kind: _MessageDetailsOperationKind.action,
      operation: () => widget.onAction(action),
      closeOnSuccess: false,
    );
  }

  String _operationErrorMessage(AppLocalizations l10n) {
    if (_error is SaveAmbiguousWriteException) {
      return l10n.inbox_saveUncertain;
    }
    if (_operationKind == _MessageDetailsOperationKind.action) {
      return l10n.inbox_actionError;
    }
    return l10n.inbox_confirmationError;
  }

  Widget _operationStatus(BuildContext context) {
    final l10n = _inboxLocalizations(context);
    if (_phase == _MessageDetailsPhase.loading) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 10),
            Text(l10n.inbox_operationSaving),
          ],
        ),
      );
    }
    if (_phase == _MessageDetailsPhase.error) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          color: Theme.of(context).colorScheme.errorContainer,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _operationErrorMessage(l10n),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _retry,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.inbox_retry),
              ),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = _inboxLocalizations(context);
    final urgent = widget.message.priority == MessagePriority.urgent;
    final expiry = widget.message.expiresAt == null
        ? null
        : DateTime.tryParse(widget.message.expiresAt!);

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
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
                      widget.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(widget.body, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 12),
              Text(
                l10n.inbox_metadata(
                  widget.message.week,
                  widget.message.day,
                  messageDomainLabel(context, widget.message.domain),
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (expiry != null) ...[
                const SizedBox(height: 6),
                Text(l10n.inbox_deadline(_formatDate(expiry))),
              ],
              _operationStatus(context),
              if (widget.message.decision != null) ...[
                const SizedBox(height: 18),
                Text(
                  l10n.inbox_decisionOptions,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                for (final option in widget.message.decision!.options)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _controlsEnabled
                            ? () => _submitDecision(option.id)
                            : null,
                        child: Text(_decisionLabel(context, option)),
                      ),
                    ),
                  ),
                Text(
                  l10n.inbox_defaultOnExpiry(
                    _decisionLabelById(
                      context,
                      widget.message,
                      widget.message.decision!.defaultOnExpiry,
                    ),
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              if (widget.message.actions.isNotEmpty) ...[
                const SizedBox(height: 18),
                Text(
                  l10n.inbox_actions,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                for (final action in widget.message.actions)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: OutlinedButton.icon(
                      onPressed: _controlsEnabled
                          ? () => _submitAction(action)
                          : null,
                      icon: const Icon(Icons.arrow_forward),
                      label: Text(_actionLabel(context, action)),
                    ),
                  ),
              ],
              if (widget.digestMembers.isNotEmpty) ...[
                const SizedBox(height: 18),
                ExpansionTile(
                  title: Text(
                    l10n.inbox_digestMembers(widget.digestMembers.length),
                  ),
                  children: [
                    for (final member in widget.digestMembers)
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
              if (urgent && widget.message.decision == null)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonal(
                    onPressed: _controlsEnabled ? _submitAcknowledge : null,
                    child: Text(l10n.inbox_acknowledge),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _closeEnabled ? widget.onCloseSheet : null,
                    child: Text(l10n.inbox_close),
                  ),
                ),
            ],
          ),
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
    final l10n = _inboxLocalizations(context);
    final id = action.id.toLowerCase();
    if (id.contains('accept') || id == 'finalize') {
      return l10n.inbox_actionAccept;
    }
    if (id.contains('decline') || id.contains('reject') || id == 'cancel') {
      return l10n.inbox_actionDecline;
    }
    if (id.contains('counter')) return l10n.inbox_actionCounter;
    if (id.contains('open') || id.contains('watchlist')) {
      return l10n.inbox_actionOpen;
    }
    return l10n.inbox_actionFallback;
  }

  static String _formatDate(DateTime value) {
    final local = value.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}
