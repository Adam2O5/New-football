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
