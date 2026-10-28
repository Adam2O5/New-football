import 'package:new_football/data/save_repository.dart';

/// Test repositories implement only their supported operations. Any other
/// operation fails immediately instead of inheriting filesystem access.
abstract class NoDiskSaveRepository implements SaveRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnsupportedError(
    'Test repository does not support ${invocation.memberName}',
  );
}
