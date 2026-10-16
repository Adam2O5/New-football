part of 'save_repository.dart';

/// The root isolate owns the coordinator. A background save keeps its
/// permission and OS lock in the caller, which releases them on worker errors.
class _SaveDirectoryCoordinator {
  static const _portName = 'new_football.save_directory_coordinator.v1';
  static SendPort? _rootPort;

  static SendPort _port() {
    if (RootIsolateToken.instance == null) {
      final existing = IsolateNameServer.lookupPortByName(_portName);
      if (existing != null) return existing;
      throw SaveRepositoryException(
        'Initialize save access on the root isolate before starting workers',
      );
    }
    if (_rootPort != null) return _rootPort!;
    // The native name map may outlive a restarted root isolate. Its old port
    // cannot serve requests; only the new root may replace that registration.
    IsolateNameServer.removePortNameMapping(_portName);
    final receiver = ReceivePort();
    final queues = <String, Queue<SendPort>>{};
    void grant(String path) {
      final released = ReceivePort();
      queues[path]!.first.send(released.sendPort);
      released.listen((_) {
        released.close();
        final queue = queues[path]!;
        queue.removeFirst();
        if (queue.isEmpty) {
          queues.remove(path);
        } else {
          grant(path);
        }
      });
    }

    receiver.listen((message) {
      final request = message as List;
      final path = request[0] as String;
      final reply = request[1] as SendPort;
      final queue = queues.putIfAbsent(path, Queue<SendPort>.new);
      queue.add(reply);
      if (queue.length == 1) grant(path);
    });
    if (!IsolateNameServer.registerPortWithName(receiver.sendPort, _portName)) {
      receiver.close();
      throw SaveRepositoryException('Cannot register the save coordinator');
    }
    _rootPort = receiver.sendPort;
    return _rootPort!;
  }

  static Future<T> run<T>(
    Directory directory,
    Future<T> Function() action,
  ) async {
    final canonical = await directory.resolveSymbolicLinks();
    final key = Platform.isWindows ? canonical.toLowerCase() : canonical;
    final coordinator = _port();
    final reply = ReceivePort();
    coordinator.send([key, reply.sendPort]);
    final release = await reply.first as SendPort;
    reply.close();
    RandomAccessFile? lock;
    var locked = false;
    try {
      lock = await File('$canonical/.save.lock').open(mode: FileMode.append);
      await lock.lock(FileLock.blockingExclusive);
      locked = true;
      return await action();
    } finally {
      try {
        if (locked) await lock!.unlock();
      } finally {
        try {
          await lock?.close();
        } finally {
          release.send(null);
        }
      }
    }
  }
}
