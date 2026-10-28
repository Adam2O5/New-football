part of '../save_management_property_cases.dart';

Future<Map<String, dynamic>> readRawJsonFile(File file) async {
  final decoded = jsonDecode(await file.readAsString());
  return Map<String, dynamic>.from(decoded as Map);
}

Future<List<Map<String, dynamic>>> readRawIndex(File file) async {
  final decoded = jsonDecode(await file.readAsString()) as List<dynamic>;
  return [for (final entry in decoded) Map<String, dynamic>.from(entry as Map)];
}

Map<String, dynamic> cloneJsonMap(Map<String, dynamic> source) {
  return Map<String, dynamic>.from(jsonDecode(jsonEncode(source)) as Map);
}

Map<String, dynamic> oracleDuplicateSnapshot(GeneratedRawSnapshot input) {
  final source = cloneJsonMap(input.sourceJson);
  final sourceMeta = Map<String, dynamic>.from(source['meta'] as Map);
  final duplicateMeta = Map<String, dynamic>.from(sourceMeta)
    ..['id'] = input.duplicateId
    ..['name'] = input.duplicateName
    ..['createdAt'] = input.duplicateTimestamp.toIso8601String()
    ..['updatedAt'] = input.duplicateTimestamp.toIso8601String();
  return <String, dynamic>{...source, 'meta': duplicateMeta};
}

Map<String, dynamic> oracleDuplicateIndexMeta(GeneratedRawSnapshot input) {
  return <String, dynamic>{
    ...input.sourceIndexMeta,
    'id': input.duplicateId,
    'name': input.duplicateName,
    'createdAt': input.duplicateTimestamp.toIso8601String(),
    'updatedAt': input.duplicateTimestamp.toIso8601String(),
  };
}

bool rawJsonValuesEqual(Object? left, Object? right) {
  if (left is Map && right is Map) {
    if (left.length != right.length) return false;
    for (final key in left.keys) {
      if (!right.containsKey(key) ||
          !rawJsonValuesEqual(left[key], right[key])) {
        return false;
      }
    }
    return true;
  }
  if (left is List && right is List) {
    if (left.length != right.length) return false;
    for (var index = 0; index < left.length; index++) {
      if (!rawJsonValuesEqual(left[index], right[index])) return false;
    }
    return true;
  }
  return left == right;
}
