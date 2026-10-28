// Run explicitly with the Dart CLI. Importing Flutter/data through either
// core service makes this fail even if Flutter widget tests still compile.
import 'dart:io';

import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/search_filters.dart';
import 'package:new_football/core/services/save_management_repository.dart';
import 'package:new_football/core/services/save_management_service.dart';
import 'package:new_football/core/services/search_filter_matching.dart';

class _EmptyStore implements SaveManagementRepository {
  @override
  Future<List<GameSaveMeta>> listSaves() async => [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> main() async {
  final records = await SaveManagementService(
    repository: _EmptyStore(),
  ).listRecords();
  if (records.isNotEmpty ||
      queryOrFiltersActive('', const SearchFiltersState())) {
    throw StateError('Unexpected defaults');
  }
  stdout.writeln(
    'Core filter and save-management boundaries: OK (plain Dart).',
  );
}
