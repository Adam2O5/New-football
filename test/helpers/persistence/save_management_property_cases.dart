import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, expectLater;
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/save_record.dart';
import 'package:new_football/data/save_repository.dart';

part 'properties/name_cases.dart';
part 'properties/copy_cases.dart';
part 'properties/raw_snapshot_cases.dart';
part 'properties/rename_cases.dart';
part 'properties/raw_io.dart';
part 'properties/index_cases.dart';
