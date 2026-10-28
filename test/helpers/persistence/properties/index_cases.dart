part of '../save_management_property_cases.dart';

final Generator<GeneratedPropertyFiveCase> generatedPropertyFiveCases = any
    .simple<GeneratedPropertyFiveCase>(
      generate: (random, size) =>
          generatePropertyFiveCase(random, size, shrunk: false),
      shrink: (input) sync* {
        if (input.shrunk) return;
        yield generatePropertyFiveCase(Random(505), 1, shrunk: true);
      },
    );

GeneratedPropertyFiveCase generatePropertyFiveCase(
  Random random,
  int size, {
  required bool shrunk,
}) {
  final normalizedSize = size < 0 ? -size : size;
  final token = random.nextInt(1 << 30);
  final saveCount = 3 + normalizedSize % 3;
  final baseTimestamp = DateTime.utc(
    2020 + normalizedSize % 5,
    1 + normalizedSize % 10,
    10,
    12,
    15,
    30,
  );
  final saves = <GeneratedPropertyFiveSave>[];

  for (var index = 0; index < saveCount; index++) {
    final updatedAt = switch (index) {
      0 || 1 => baseTimestamp,
      2 => baseTimestamp.add(const Duration(hours: 1)),
      3 => baseTimestamp.subtract(const Duration(hours: 1)),
      _ => baseTimestamp.add(Duration(hours: index + 1)),
    };
    final createdAt = updatedAt.subtract(const Duration(days: 1));
    final id = 'p5-save-$token-$index';
    final name = index.isEven
        ? ' p5-save-$token-$index\n'
        : '\tp5-save-$token-$index\r ';
    final schemaVersion = (index % 3) - 1;
    final phase = SeasonPhase
        .values[(index + normalizedSize) % SeasonPhase.values.length];
    final indexMeta = <String, dynamic>{
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'seasonYear': 2020 + index,
      'phase': phase.name,
      'playerTeamName': index.isEven ? 'P5 Team $index' : null,
      'schemaVersion': schemaVersion,
    };
    final rawJson = <String, dynamic>{
      'schemaVersion': schemaVersion + 10,
      'meta': <String, dynamic>{
        ...cloneJsonMap(indexMeta),
        'futureMeta': <String, dynamic>{
          'caseToken': token,
          'saveIndex': index,
          'preserve': <dynamic>[index, 'meta-$token'],
        },
      },
      'leagueState': <String, dynamic>{
        'payloadMarker': 'p5-payload-$token-$index',
        'nested': <dynamic>[
          index,
          token,
          <String, dynamic>{'keep': true},
        ],
      },
      'saveSeed': token - index,
      'futureTopLevel': <String, dynamic>{
        'caseToken': token,
        'saveIndex': index,
        'preserve': <dynamic>['top-level', index],
      },
    };
    saves.add(
      GeneratedPropertyFiveSave(
        id: id,
        name: name,
        updatedAt: updatedAt,
        indexMeta: indexMeta,
        rawJson: rawJson,
      ),
    );
  }

  final initialIndexOrder = List<int>.generate(saveCount, (index) => index)
    ..shuffle(random);
  final duplicateTimestamp = normalizedSize.isEven
      ? baseTimestamp
      : baseTimestamp.add(const Duration(days: 5));
  final locale = random.nextBool() ? 'en' : 'pl';

  return GeneratedPropertyFiveCase(
    saves: saves,
    initialIndexOrder: initialIndexOrder,
    duplicateSourceId: saves.first.id,
    renameId: saves[1].id,
    duplicateId: 'p5-copy-$token',
    duplicateTimestamp: duplicateTimestamp,
    locale: locale,
    proposedName: ' \tp5-renamed-$token \n',
    shrunk: shrunk,
  );
}

class GeneratedPropertyFiveCase {
  const GeneratedPropertyFiveCase({
    required this.saves,
    required this.initialIndexOrder,
    required this.duplicateSourceId,
    required this.renameId,
    required this.duplicateId,
    required this.duplicateTimestamp,
    required this.locale,
    required this.proposedName,
    required this.shrunk,
  });

  final List<GeneratedPropertyFiveSave> saves;
  final List<int> initialIndexOrder;
  final String duplicateSourceId;
  final String renameId;
  final String duplicateId;
  final DateTime duplicateTimestamp;
  final String locale;
  final String proposedName;
  final bool shrunk;

  @override
  String toString() =>
      'GeneratedPropertyFiveCase('
      'ids: ${saves.map((save) => save.id).toList()}, '
      'duplicateSourceId: $duplicateSourceId, '
      'renameId: $renameId, duplicateId: $duplicateId, '
      'duplicateTimestamp: $duplicateTimestamp, locale: $locale, '
      'proposedName: ${proposedName.replaceAll('\n', r'\n')}, '
      'shrunk: $shrunk)';
}

class GeneratedPropertyFiveSave {
  const GeneratedPropertyFiveSave({
    required this.id,
    required this.name,
    required this.updatedAt,
    required this.indexMeta,
    required this.rawJson,
  });

  final String id;
  final String name;
  final DateTime updatedAt;
  final Map<String, dynamic> indexMeta;
  final Map<String, dynamic> rawJson;
}
