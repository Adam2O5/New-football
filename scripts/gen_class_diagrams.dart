import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';

/// Generates Mermaid architecture diagrams from the AST of `lib/`.
///
/// Run from the repository root with the Dart SDK shipped with Flutter 3.41.4:
/// `dart run scripts/gen_class_diagrams.dart`
///
/// Stage 2 pages are further entries in [groups]:
/// `services.md`, `simulation.md` (`lib/core/simulation` + `lib/core/tactics`),
/// `ai.md`, `balance.md`, `persistence.md` (`lib/data` + `lib/core/random`)
/// and `app.md` (providers, plus screens as a screen-to-provider list).

final class OverviewPackage {
  const OverviewPackage(this.id, this.directory, this.layer);

  final String id;
  final String directory;
  final int layer;
}

/// Higher layers may import lower layers. A lower layer importing a higher
/// one, an edge inside a cycle, or a screen import that skips providers is red.
const overviewPackages = <OverviewPackage>[
  OverviewPackage('core/models', 'lib/core/models', 0),
  OverviewPackage('core/random', 'lib/core/random', 0),
  OverviewPackage('core/tactics', 'lib/core/tactics', 1),
  OverviewPackage('core/balance', 'lib/core/balance', 1),
  OverviewPackage('core/simulation', 'lib/core/simulation', 2),
  OverviewPackage('core/ai', 'lib/core/ai', 3),
  OverviewPackage('data', 'lib/data', 4),
  OverviewPackage('core/services', 'lib/core/services', 5),
  OverviewPackage('app/providers', 'lib/app/providers', 6),
  OverviewPackage('app/screens', 'lib/app/screens', 7),
];

/// Edges the review expects to see in red. `services` ↔ `ai` is the pair.
const expectedRedEdges = <(String, String)>[
  ('core/models', 'core/services'),
  ('core/simulation', 'core/services'),
  ('core/balance', 'core/ai'),
  ('core/services', 'core/ai'),
  ('core/ai', 'core/services'),
  ('app/screens', 'core/services'),
];

final class DiagramFile {
  const DiagramFile(this.path, {this.only});

  /// Repo-relative posix path.
  final String path;

  /// When set, only these public type names from [path] are included.
  final Set<String>? only;
}

final class DiagramGroup {
  const DiagramGroup({
    required this.page,
    required this.title,
    required this.description,
    required this.files,
  });

  final String page;
  final String title;
  final String description;
  final List<DiagramFile> files;
}

/// Every class-diagram file group. Insertion order is the document order.
/// Several groups may share one [DiagramGroup.page].
const groups = <String, DiagramGroup>{
  'models.league': DiagramGroup(
    page: 'models.md',
    title: 'Liga, sezon i tabela',
    description:
        'Sezon i jego fazy, tabele konferencji, drabinka play-off, play-in, '
        'siła ligi, loteria draftu oraz koperta zapisu (`GameSave`, '
        '`SaveRecord`). `LeagueState` trzyma też drużyny, skrzynkę i '
        'negocjacje — ich klasy są na kolejnych diagramach. Z `enums.dart` '
        'są tu `Conference`, `SeasonPhase`, `PlayoffRound`, `TeamStatus` i '
        '`TeamOfSeasonSlot`.',
    files: [
      DiagramFile('lib/core/models/league_state.dart'),
      DiagramFile('lib/core/models/season.dart'),
      DiagramFile('lib/core/models/season_awards.dart'),
      DiagramFile('lib/core/models/season_history.dart'),
      DiagramFile('lib/core/models/standing.dart'),
      DiagramFile('lib/core/models/league_strength.dart'),
      DiagramFile('lib/core/models/playoff_bracket.dart'),
      DiagramFile('lib/core/models/play_in_models.dart'),
      DiagramFile('lib/core/models/lottery_models.dart'),
      DiagramFile('lib/core/models/lottery_result.dart'),
      DiagramFile('lib/core/models/game_save.dart'),
      DiagramFile('lib/core/models/save_record.dart'),
      DiagramFile(
        'lib/core/models/enums.dart',
        only: {
          'Conference',
          'SeasonPhase',
          'PlayoffRound',
          'TeamStatus',
          'TeamOfSeasonSlot',
        },
      ),
    ],
  ),
  'models.squad': DiagramGroup(
    page: 'models.md',
    title: 'Zawodnik, drużyna i sztab',
    description:
        'Zawodnik, atrybuty z pola i bramkarza, rola, kontuzja, skauting oraz '
        'drużyna ze sztabem, historią tygodnia i statystykami sezonu. Kontrakt, '
        'pick draftu i taktyka są polami `Team` i `Player`, a ich klasy są na '
        'diagramie kontraktów albo w `core/tactics`. Z `enums.dart` są tu '
        '`Position`, `StaffRole`, `InjuryType` i `InjuryGroup`.',
    files: [
      DiagramFile('lib/core/models/player.dart'),
      DiagramFile('lib/core/models/player_attributes.dart'),
      DiagramFile('lib/core/models/field_player_attributes.dart'),
      DiagramFile('lib/core/models/goalkeeper_attributes.dart'),
      DiagramFile('lib/core/models/assigned_role.dart'),
      DiagramFile('lib/core/models/team.dart'),
      DiagramFile('lib/core/models/staff.dart'),
      DiagramFile('lib/core/models/injury.dart'),
      DiagramFile('lib/core/models/scouting.dart'),
      DiagramFile(
        'lib/core/models/enums.dart',
        only: {'Position', 'StaffRole', 'InjuryType', 'InjuryGroup'},
      ),
    ],
  ),
  'models.market': DiagramGroup(
    page: 'models.md',
    title: 'Kontrakty, wymiany i draft',
    description:
        'Kontrakt zawodnika, wyjątki od capu, finanse klubu, negocjacje, prawa '
        'draftu, RFA, oferty wymiany, stan draftu i prospect. Z `enums.dart` '
        'są tu `CapExceptionType` i `EstimatedDraftSlot`.',
    files: [
      DiagramFile('lib/core/models/contract.dart'),
      DiagramFile('lib/core/models/contract_market_models.dart'),
      DiagramFile('lib/core/models/contract_negotiation.dart'),
      DiagramFile('lib/core/models/trade_models.dart'),
      DiagramFile('lib/core/models/draft_class.dart'),
      DiagramFile('lib/core/models/draft_pick.dart'),
      DiagramFile('lib/core/models/draft_state.dart'),
      DiagramFile('lib/core/models/prospect.dart'),
      DiagramFile(
        'lib/core/models/enums.dart',
        only: {'CapExceptionType', 'EstimatedDraftSlot'},
      ),
    ],
  ),
  'models.match': DiagramGroup(
    page: 'models.md',
    title: 'Mecz, wiadomości i zdarzenia',
    description:
        'Zdarzenia i statystyki meczu, konfiguracja spotkania, stan symulacji, '
        'skrzynka wiadomości oraz modyfikatory zawodnika i drużyny. Z '
        '`enums.dart` są tu `MatchEventType`, `MatchStatus`, `MatchStake`, '
        '`MessageType`, `MessageDomain` i `MessagePriority`.',
    files: [
      DiagramFile('lib/core/models/match_models.dart'),
      DiagramFile('lib/core/models/match_state.dart'),
      DiagramFile('lib/core/models/message.dart'),
      DiagramFile('lib/core/models/player_event_state.dart'),
      DiagramFile('lib/core/models/team_event_state.dart'),
      DiagramFile(
        'lib/core/models/enums.dart',
        only: {
          'MatchEventType',
          'MatchStatus',
          'MatchStake',
          'MessageType',
          'MessageDomain',
          'MessagePriority',
        },
      ),
    ],
  ),
};

const _skippedMembers = <String>{
  'copyWith',
  'toJson',
  'fromJson',
  'hashCode',
  'toString',
};

const _collectionTypes = <String>{'List', 'Set', 'Iterable', 'Map'};

const _maxTypesPerDiagram = 45;

const _generatedBanner =
    '<!-- Generated by scripts/gen_class_diagrams.dart. Do not edit by hand. -->';

void main() {
  final root = findRepoRoot();
  final importGraph = scanImports(root);
  final diagrams = [
    for (final entry in groups.entries)
      renderGroup(root, entry.key, entry.value),
  ];
  final outDir = Directory('${root.path}/docs/architecture');
  outDir.createSync(recursive: true);

  File(
    '${outDir.path}/README.md',
  ).writeAsStringSync(renderReadme(importGraph, diagrams));

  final byPage = <String, List<RenderedDiagram>>{};
  for (final diagram in diagrams) {
    byPage.putIfAbsent(diagram.page, () => []).add(diagram);
  }
  final omitted = omittedModelFiles(root);
  for (final entry in byPage.entries) {
    File(
      '${outDir.path}/${entry.key}',
    ).writeAsStringSync(renderPage(entry.key, entry.value, omitted));
  }

  stdout.writeln('Wrote docs/architecture/README.md');
  for (final page in byPage.keys) {
    stdout.writeln('Wrote docs/architecture/$page');
  }
  for (final diagram in diagrams) {
    stdout.writeln(
      '${diagram.id}: ${diagram.typeCount} types, ${diagram.mermaid.length} chars',
    );
  }
  final red = importGraph.edges.where((edge) => edge.red).length;
  stdout.writeln(
    'Imports: ${importGraph.edges.length} edges, $red red, '
    'cycles: ${importGraph.cycles.map((cycle) => cycle.join('+')).join(' | ')}',
  );
  for (final expected in expectedRedEdges) {
    final match = importGraph.edges.where(
      (edge) => edge.from == expected.$1 && edge.to == expected.$2,
    );
    if (match.isEmpty) {
      stdout.writeln('MISSING ${expected.$1} -> ${expected.$2}');
    } else if (!match.single.red) {
      stdout.writeln(
        'NOT RED ${expected.$1} -> ${expected.$2} (${match.single.count})',
      );
    } else {
      stdout.writeln(
        'confirmed ${expected.$1} -> ${expected.$2} = ${match.single.count}',
      );
    }
  }
}

Directory findRepoRoot() {
  var dir = Directory.current.absolute;
  while (true) {
    final pubspec = File('${dir.path}/pubspec.yaml');
    final script = File('${dir.path}/scripts/gen_class_diagrams.dart');
    if (pubspec.existsSync() && script.existsSync()) return dir;
    final parent = dir.parent;
    if (parent.path == dir.path) {
      throw StateError('Run this script from the New Football repository.');
    }
    dir = parent;
  }
}

bool isGeneratedPath(String relative) {
  if (!relative.startsWith('lib/') || !relative.endsWith('.dart')) return true;
  if (relative.endsWith('.g.dart') || relative.endsWith('.freezed.dart')) {
    return true;
  }
  if (relative == 'lib/l10n/generated' ||
      relative.startsWith('lib/l10n/generated/')) {
    return true;
  }
  return false;
}

String? packageOf(String relative) {
  final path = relative.startsWith('lib/') ? relative.substring(4) : relative;
  for (final package in overviewPackages) {
    final directory = package.directory.startsWith('lib/')
        ? package.directory.substring(4)
        : package.directory;
    if (path == directory || path.startsWith('$directory/')) return package.id;
  }
  return null;
}

int layerOf(String id) {
  for (final package in overviewPackages) {
    if (package.id == id) return package.layer;
  }
  throw StateError('Unknown package $id');
}

int packageIndex(String id) {
  for (var i = 0; i < overviewPackages.length; i++) {
    if (overviewPackages[i].id == id) return i;
  }
  return overviewPackages.length;
}

String nodeId(String packageId) => 'pkg_${packageId.replaceAll('/', '_')}';

final class ImportEdge {
  const ImportEdge({
    required this.from,
    required this.to,
    required this.count,
    required this.sample,
    required this.reasons,
  });

  final String from;
  final String to;
  final int count;
  final String sample;
  final List<String> reasons;

  bool get red => reasons.isNotEmpty;
}

final class ImportGraph {
  const ImportGraph(this.edges, this.cycles);

  final List<ImportEdge> edges;
  final List<List<String>> cycles;
}

final class _ImportAccum {
  int count = 0;
  String? sample;
}

ImportGraph scanImports(Directory root) {
  final counts = <(String, String), _ImportAccum>{};
  final files =
      Directory('${root.path}/lib')
          .listSync(recursive: true)
          .whereType<File>()
          .map((file) => relativePosix(root.path, file.path))
          .where((path) => !isGeneratedPath(path))
          .toList()
        ..sort();

  for (final relative in files) {
    final fromPackage = packageOf(relative);
    if (fromPackage == null) continue;
    final unit = parseDart(File('${root.path}/$relative'), relative);
    for (final directive in unit.directives) {
      if (directive is! ImportDirective) continue;
      final uri = directive.uri.stringValue;
      if (uri == null) continue;
      final target = resolveImport(relative, uri);
      if (target == null) continue;
      final toPackage = packageOf(target);
      if (toPackage == null || toPackage == fromPackage) continue;
      final sample = '$relative -> $uri';
      final accum = counts.putIfAbsent((
        fromPackage,
        toPackage,
      ), _ImportAccum.new);
      accum.count += 1;
      if (accum.sample == null || sample.compareTo(accum.sample!) < 0) {
        accum.sample = sample;
      }
    }
  }

  if (expectedRedEdges.every((edge) => !counts.containsKey(edge))) {
    throw StateError('Import scan matched none of the expected edges.');
  }

  final graph = <String, Set<String>>{
    for (final package in overviewPackages) package.id: <String>{},
  };
  for (final entry in counts.entries) {
    graph[entry.key.$1]!.add(entry.key.$2);
  }
  final components = stronglyConnected(graph.keys.toSet(), graph);
  final componentOf = <String, int>{};
  for (var i = 0; i < components.length; i++) {
    for (final node in components[i]) {
      componentOf[node] = i;
    }
  }

  final cycles = [
    for (final component in components)
      if (component.length > 1) (component.toList()..sort()),
  ]..sort((a, b) => a.join().compareTo(b.join()));

  final keys = counts.keys.toList()
    ..sort((a, b) {
      final byFrom = packageIndex(a.$1).compareTo(packageIndex(b.$1));
      if (byFrom != 0) return byFrom;
      return packageIndex(a.$2).compareTo(packageIndex(b.$2));
    });

  final edges = <ImportEdge>[];
  for (final key in keys) {
    final reasons = <String>[];
    final fromComponent = componentOf[key.$1];
    final toComponent = componentOf[key.$2];
    if (fromComponent != null &&
        fromComponent == toComponent &&
        components[fromComponent].length > 1) {
      reasons.add('cykl');
    }
    if (layerOf(key.$1) < layerOf(key.$2)) reasons.add('warstwa w górę');
    if (key.$1 == 'app/screens' &&
        key.$2 != 'app/providers' &&
        key.$2 != 'core/models') {
      reasons.add('omija providers');
    }
    edges.add(
      ImportEdge(
        from: key.$1,
        to: key.$2,
        count: counts[key]!.count,
        sample: counts[key]!.sample ?? '',
        reasons: reasons,
      ),
    );
  }
  return ImportGraph(edges, cycles);
}

List<Set<String>> stronglyConnected(
  Set<String> nodes,
  Map<String, Set<String>> graph,
) {
  final ordered = nodes.toList()..sort();
  final seen = <String>{};
  final finish = <String>[];

  void forward(String node) {
    if (!seen.add(node)) return;
    final next = (graph[node] ?? const <String>{}).toList()..sort();
    for (final target in next) {
      forward(target);
    }
    finish.add(node);
  }

  for (final node in ordered) {
    forward(node);
  }

  final reverse = <String, Set<String>>{
    for (final node in ordered) node: <String>{},
  };
  for (final entry in graph.entries) {
    for (final target in entry.value) {
      reverse.putIfAbsent(target, () => <String>{}).add(entry.key);
    }
  }

  seen.clear();
  final components = <Set<String>>[];
  void backward(String node, Set<String> bucket) {
    if (!seen.add(node)) return;
    bucket.add(node);
    final next = (reverse[node] ?? const <String>{}).toList()..sort();
    for (final target in next) {
      backward(target, bucket);
    }
  }

  for (final node in finish.reversed) {
    if (seen.contains(node)) continue;
    final bucket = <String>{};
    backward(node, bucket);
    components.add(bucket);
  }
  return components;
}

String? resolveImport(String fromRelative, String uri) {
  if (uri.startsWith('dart:')) return null;
  const packagePrefix = 'package:new_football/';
  if (uri.startsWith('package:')) {
    if (!uri.startsWith(packagePrefix)) return null;
    return uri.substring(packagePrefix.length);
  }
  if (uri.contains(':')) return null;
  final slash = fromRelative.lastIndexOf('/');
  final directory = slash == -1 ? '' : fromRelative.substring(0, slash);
  return normalizePosix(directory.isEmpty ? uri : '$directory/$uri');
}

String normalizePosix(String path) {
  final parts = <String>[];
  for (final part in path.split('/')) {
    if (part.isEmpty || part == '.') continue;
    if (part == '..') {
      if (parts.isNotEmpty) parts.removeLast();
      continue;
    }
    parts.add(part);
  }
  return parts.join('/');
}

String relativePosix(String root, String absolute) {
  final prefix = root.endsWith('/') ? root : '$root/';
  final relative = absolute.startsWith(prefix)
      ? absolute.substring(prefix.length)
      : absolute;
  return relative.replaceAll('\\', '/');
}

CompilationUnit parseDart(File file, String relative) {
  return parseString(content: file.readAsStringSync(), path: relative).unit;
}

enum _TypeKind { classKind, mixinKind, enumKind, extensionKind }

enum _RelKind { extendsRel, implementsRel, composition, dependency }

final class _Field {
  _Field({required this.name, required this.type, required this.isStatic});

  final String name;
  String type;
  final bool isStatic;
  bool compositional = false;
  TypeAnnotation? sourceType;
}

final class _Member {
  const _Member(this.name, this.rendered);

  final String name;
  final String rendered;
}

final class _Relation {
  const _Relation({
    required this.kind,
    required this.source,
    required this.target,
    required this.label,
    required this.many,
    required this.nullable,
  });

  final _RelKind kind;
  final String source;
  final String target;
  final String label;
  final bool many;
  final bool nullable;
}

final class _TypeModel {
  _TypeModel({
    required this.simpleName,
    required this.id,
    required this.kind,
    required this.compositional,
  });

  final String simpleName;
  final String id;
  final _TypeKind kind;
  final bool compositional;
  bool freezed = false;
  final List<String> stereotypes = [];
  final List<String> enumConstants = [];
  final Map<String, _Field> fields = {};
  final Map<String, _Member> methods = {};
  final List<ConstructorDeclaration> constructors = [];
  NamedType? superclass;
  final List<NamedType> mixins = [];
  final List<NamedType> interfaces = [];
  final List<NamedType> constraints = [];
  TypeAnnotation? extendedType;
}

final class RenderedDiagram {
  const RenderedDiagram({
    required this.id,
    required this.page,
    required this.title,
    required this.description,
    required this.files,
    required this.typeCount,
    required this.mermaid,
  });

  final String id;
  final String page;
  final String title;
  final String description;
  final List<String> files;
  final int typeCount;
  final String mermaid;
}

RenderedDiagram renderGroup(Directory root, String id, DiagramGroup group) {
  final types = <_TypeModel>[];
  final seenNames = <String, String>{};
  for (final file in group.files) {
    final source = File('${root.path}/${file.path}');
    if (!source.existsSync()) {
      throw StateError('Missing diagram file ${file.path}');
    }
    final unit = parseDart(source, file.path);
    final found = <String>{};
    for (final declaration in unit.declarations) {
      final model = _readDeclaration(declaration);
      if (model == null || model.simpleName.startsWith('_')) continue;
      found.add(model.simpleName);
      if (file.only != null && !file.only!.contains(model.simpleName)) {
        continue;
      }
      final previous = seenNames[model.simpleName];
      if (previous != null) {
        throw StateError(
          'Duplicate type ${model.simpleName} in $id '
          '($previous and ${file.path})',
        );
      }
      seenNames[model.simpleName] = file.path;
      types.add(model);
    }
    if (file.only != null) {
      final missing = file.only!.difference(found).toList()..sort();
      if (missing.isNotEmpty) {
        throw StateError(
          '${file.path} is missing ${missing.join(', ')} for $id',
        );
      }
    }
  }

  if (types.length > _maxTypesPerDiagram) {
    final names = types.map((type) => type.simpleName).toList()..sort();
    throw StateError(
      '$id has ${types.length} types (limit $_maxTypesPerDiagram): '
      '${names.join(', ')}',
    );
  }

  final byName = {for (final type in types) type.simpleName: type.id};
  final relations = <_Relation>[
    for (final type in types) ..._relationsFor(type, byName),
  ];
  types.sort((a, b) => a.id.compareTo(b.id));
  final mermaid = _renderClassDiagram(types, relations);
  _assertMermaidSafe(id, mermaid);
  return RenderedDiagram(
    id: id,
    page: group.page,
    title: group.title,
    description: group.description,
    files: [for (final file in group.files) file.path],
    typeCount: types.length,
    mermaid: mermaid,
  );
}

void _assertMermaidSafe(String id, String mermaid) {
  final stripped = mermaid
      .replaceAll(RegExp(r'<<[A-Za-z]+>>'), '')
      .replaceAll('<|--', '')
      .replaceAll('<|..', '')
      .replaceAll('..>', '');
  if (stripped.contains('<') || stripped.contains('>')) {
    throw StateError('$id still contains raw angle brackets');
  }
}

_TypeModel? _readDeclaration(CompilationUnitMember declaration) {
  if (declaration is ClassDeclaration) return _readClass(declaration);
  if (declaration is MixinDeclaration) return _readMixin(declaration);
  if (declaration is EnumDeclaration) return _readEnum(declaration);
  if (declaration is ExtensionDeclaration) return _readExtension(declaration);
  if (declaration is ExtensionTypeDeclaration) {
    return _readExtensionType(declaration);
  }
  return null;
}

_TypeModel _readClass(ClassDeclaration declaration) {
  final name = declaration.namePart.typeName.lexeme;
  final model = _TypeModel(
    simpleName: name,
    id: _typeId(name, declaration.namePart.typeParameters),
    kind: _TypeKind.classKind,
    compositional: true,
  );
  model.freezed = _isFreezed(declaration, declaration.withClause);
  if (declaration.mixinKeyword != null) model.stereotypes.add('mixin');
  if (model.freezed) model.stereotypes.add('freezed');
  model.superclass = declaration.extendsClause?.superclass;
  model.mixins.addAll(declaration.withClause?.mixinTypes ?? const []);
  model.interfaces.addAll(declaration.implementsClause?.interfaces ?? const []);
  _collectMembers(model, _bodyMembers(declaration.body));
  return model;
}

_TypeModel _readMixin(MixinDeclaration declaration) {
  final name = declaration.name.lexeme;
  final model = _TypeModel(
    simpleName: name,
    id: _typeId(name, declaration.typeParameters),
    kind: _TypeKind.mixinKind,
    compositional: true,
  );
  model.stereotypes.add('mixin');
  model.freezed = _isFreezed(declaration, null);
  if (model.freezed) model.stereotypes.add('freezed');
  model.constraints.addAll(
    declaration.onClause?.superclassConstraints ?? const [],
  );
  model.interfaces.addAll(declaration.implementsClause?.interfaces ?? const []);
  _collectMembers(model, declaration.body.members);
  return model;
}

_TypeModel _readEnum(EnumDeclaration declaration) {
  final name = declaration.namePart.typeName.lexeme;
  final model = _TypeModel(
    simpleName: name,
    id: _typeId(name, declaration.namePart.typeParameters),
    kind: _TypeKind.enumKind,
    compositional: true,
  );
  model.stereotypes.add('enumeration');
  model.freezed = _isFreezed(declaration, declaration.withClause);
  if (model.freezed) model.stereotypes.add('freezed');
  model.mixins.addAll(declaration.withClause?.mixinTypes ?? const []);
  model.interfaces.addAll(declaration.implementsClause?.interfaces ?? const []);
  for (final constant in declaration.body.constants) {
    final constantName = constant.name.lexeme;
    if (!constantName.startsWith('_')) model.enumConstants.add(constantName);
  }
  model.enumConstants.sort();
  _collectMembers(model, declaration.body.members);
  return model;
}

_TypeModel _readExtension(ExtensionDeclaration declaration) {
  final onType = declaration.onClause?.extendedType;
  final name = declaration.name?.lexeme ?? _anonymousExtensionName(onType);
  final model = _TypeModel(
    simpleName: name,
    id: _typeId(name, declaration.typeParameters),
    kind: _TypeKind.extensionKind,
    compositional: false,
  );
  model.stereotypes.add('extension');
  model.extendedType = onType;
  _collectMembers(model, declaration.body.members);
  return model;
}

_TypeModel _readExtensionType(ExtensionTypeDeclaration declaration) {
  final name = declaration.primaryConstructor.typeName.lexeme;
  final model = _TypeModel(
    simpleName: name,
    id: _typeId(name, declaration.primaryConstructor.typeParameters),
    kind: _TypeKind.classKind,
    compositional: true,
  );
  model.stereotypes.add('extensionType');
  model.interfaces.addAll(declaration.implementsClause?.interfaces ?? const []);
  for (final parameter
      in declaration.primaryConstructor.formalParameters.parameters) {
    _addParameterField(model, parameter);
  }
  _collectMembers(model, _bodyMembers(declaration.body));
  return model;
}

String _anonymousExtensionName(TypeAnnotation? onType) {
  if (onType is NamedType) return 'ExtensionOn${onType.name.lexeme}';
  return 'AnonymousExtension';
}

String _typeId(String name, TypeParameterList? parameters) {
  const reserved = {'end', 'class', 'style', 'direction', 'click', 'callback'};
  var safe = name.replaceAll(RegExp(r'[^A-Za-z0-9_]'), '_');
  if (reserved.contains(safe)) safe = '${safe}Type';
  if (parameters == null || parameters.typeParameters.isEmpty) return safe;
  final args = parameters.typeParameters
      .map((parameter) => parameter.name.lexeme)
      .join(', ');
  return '$safe~$args~';
}

bool _isFreezed(AnnotatedNode node, WithClause? withClause) {
  for (final annotation in node.metadata) {
    final name = annotation.name;
    final short = name is PrefixedIdentifier ? name.identifier.name : name.name;
    if (short == 'freezed' || short == 'Freezed') return true;
  }
  if (withClause == null) return false;
  return withClause.mixinTypes.any(
    (type) => type.name.lexeme.startsWith(r'_$'),
  );
}

List<ClassMember> _bodyMembers(ClassBody body) {
  if (body is BlockClassBody) return body.members;
  return const [];
}

void _collectMembers(_TypeModel model, List<ClassMember> members) {
  for (final member in members) {
    if (member is FieldDeclaration) {
      final annotation = member.fields.type;
      final rendered = annotation == null ? '' : _renderType(annotation);
      for (final variable in member.fields.variables) {
        _addField(
          model,
          variable.name.lexeme,
          rendered,
          isStatic: member.isStatic,
          compositional: model.compositional && !member.isStatic,
          sourceType: annotation,
        );
      }
    } else if (member is MethodDeclaration) {
      _addMethod(model, member);
    } else if (member is ConstructorDeclaration) {
      model.constructors.add(member);
    }
  }
  if (!model.freezed) return;
  for (final constructor in model.constructors) {
    if (constructor.factoryKeyword == null || constructor.name != null) {
      continue;
    }
    for (final parameter in constructor.parameters.parameters) {
      _addParameterField(model, parameter);
    }
  }
}

void _addParameterField(_TypeModel model, FormalParameter parameter) {
  final inner = _unwrapParameter(parameter);
  final name = inner.name?.lexeme;
  if (name == null || name.startsWith('_')) return;
  final annotation = _parameterType(inner);
  _addField(
    model,
    name,
    annotation == null ? '' : _renderType(annotation),
    isStatic: false,
    compositional: true,
    sourceType: annotation,
  );
}

void _addField(
  _TypeModel model,
  String name,
  String type, {
  required bool isStatic,
  required bool compositional,
  required TypeAnnotation? sourceType,
}) {
  if (name.startsWith('_') || _skippedMembers.contains(name)) return;
  final existing = model.fields[name];
  if (existing != null) {
    if (existing.type.isEmpty && type.isNotEmpty) {
      existing.type = type;
      existing.sourceType ??= sourceType;
    }
    return;
  }
  model.fields[name] = _Field(name: name, type: type, isStatic: isStatic)
    ..compositional = compositional
    ..sourceType = sourceType;
}

void _addMethod(_TypeModel model, MethodDeclaration method) {
  final name = method.name.lexeme;
  if (name.startsWith('_') || _skippedMembers.contains(name)) return;
  if (method.isOperator || name == '==' || method.isSetter) return;
  if (method.isGetter) {
    _addField(
      model,
      name,
      method.returnType == null ? '' : _renderType(method.returnType!),
      isStatic: method.isStatic,
      compositional: false,
      sourceType: null,
    );
    return;
  }
  if (model.methods.containsKey(name)) return;
  final parameters = method.parameters;
  final renderedParameters = parameters == null
      ? ''
      : _renderParameters(parameters.parameters);
  final returnType = method.returnType == null
      ? ''
      : _renderType(method.returnType!);
  final buffer = StringBuffer('+$name($renderedParameters)');
  if (returnType.isNotEmpty) buffer.write(' $returnType');
  if (method.isStatic) buffer.write(r'$');
  model.methods[name] = _Member(name, _sanitizeMember(buffer.toString()));
}

String _renderParameters(List<FormalParameter> parameters) {
  final parts = <String>[];
  for (final parameter in parameters) {
    final inner = _unwrapParameter(parameter);
    final name = inner.name?.lexeme ?? '';
    if (name.startsWith('_')) continue;
    final annotation = _parameterType(inner);
    final type = annotation == null ? '' : _renderType(annotation);
    final piece = [
      if (type.isNotEmpty) type,
      if (name.isNotEmpty) name,
    ].join(' ');
    if (piece.isNotEmpty) parts.add(piece);
  }
  var joined = parts.join(', ');
  if (joined.length > 96) joined = '${joined.substring(0, 93)}...';
  return _sanitizeMember(joined);
}

FormalParameter _unwrapParameter(FormalParameter parameter) {
  if (parameter is DefaultFormalParameter) return parameter.parameter;
  return parameter;
}

TypeAnnotation? _parameterType(FormalParameter parameter) {
  if (parameter is SimpleFormalParameter) return parameter.type;
  if (parameter is FieldFormalParameter) return parameter.type;
  if (parameter is SuperFormalParameter) return parameter.type;
  return null;
}

String _renderType(TypeAnnotation type) {
  if (type is NamedType) {
    final arguments = type.typeArguments?.arguments;
    final nullable = type.question == null ? '' : '?';
    if (arguments == null || arguments.isEmpty) {
      return '${type.name.lexeme}$nullable';
    }
    final inner = arguments.map(_renderType).join(', ');
    return '${type.name.lexeme}~$inner~$nullable';
  }
  if (type is GenericFunctionType) return 'Function';
  if (type is RecordTypeAnnotation) return 'Record';
  return 'Type';
}

String _sanitizeMember(String input) {
  const allowed =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
      r'0123456789_~ ?,./+-$()';
  final buffer = StringBuffer();
  for (final rune in input.runes) {
    final char = String.fromCharCode(rune);
    if (allowed.contains(char)) {
      buffer.write(char);
    } else if (char == '<' || char == '>') {
      buffer.write('~');
    } else if (char == '\n' || char == '\r' || char == '\t') {
      buffer.write(' ');
    }
  }
  return buffer.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
}

List<String> _linkedTypeNames(TypeAnnotation type) {
  if (type is NamedType) {
    final name = type.name.lexeme;
    final arguments = type.typeArguments?.arguments;
    if (_collectionTypes.contains(name)) {
      if (arguments == null) return const [];
      return [for (final argument in arguments) ..._linkedTypeNames(argument)];
    }
    return [name];
  }
  if (type is RecordTypeAnnotation) {
    final names = <String>[];
    for (final field in type.positionalFields) {
      names.addAll(_linkedTypeNames(field.type));
    }
    final named = type.namedFields;
    if (named != null) {
      for (final field in named.fields) {
        names.addAll(_linkedTypeNames(field.type));
      }
    }
    return names;
  }
  return const [];
}

List<_Relation> _relationsFor(_TypeModel type, Map<String, String> byName) {
  final relations = <_Relation>[];
  final composed = <String>{};

  void addRelation({
    required _RelKind kind,
    required String? targetName,
    required String label,
    bool many = false,
    bool nullable = false,
  }) {
    if (targetName == null || targetName.startsWith('_')) return;
    final target = byName[targetName];
    if (target == null) return;
    relations.add(
      _Relation(
        kind: kind,
        source: type.id,
        target: target,
        label: _safeLabel(label),
        many: many,
        nullable: nullable,
      ),
    );
    if (kind == _RelKind.composition) composed.add(target);
  }

  for (final constructor in type.constructors) {
    for (final parameter in constructor.parameters.parameters) {
      final inner = _unwrapParameter(parameter);
      if (inner is! FieldFormalParameter || inner.type == null) continue;
      final field = type.fields[inner.name.lexeme];
      if (field != null && field.type.isEmpty) {
        field.type = _renderType(inner.type!);
        field.sourceType ??= inner.type;
      }
    }
  }

  for (final field in type.fields.values) {
    final sourceType = field.sourceType;
    if (!field.compositional || sourceType == null) continue;
    final shape = _collectionShape(sourceType);
    for (final targetName in _linkedTypeNames(sourceType)) {
      addRelation(
        kind: _RelKind.composition,
        targetName: targetName,
        label: field.name,
        many: shape.many,
        nullable: shape.nullable && !shape.many,
      );
    }
  }

  for (final constructor in type.constructors) {
    final constructorName = constructor.name?.lexeme;
    if (constructorName != null &&
        (constructorName.startsWith('_') ||
            _skippedMembers.contains(constructorName))) {
      continue;
    }
    final primaryFreezed =
        type.freezed &&
        constructor.factoryKeyword != null &&
        constructor.name == null;
    if (primaryFreezed) continue;
    for (final parameter in constructor.parameters.parameters) {
      final inner = _unwrapParameter(parameter);
      if (inner is FieldFormalParameter) continue;
      final annotation = _parameterType(inner);
      if (annotation == null) continue;
      final label = inner.name?.lexeme ?? 'ctor';
      for (final targetName in _linkedTypeNames(annotation)) {
        final target = byName[targetName];
        if (target == null || composed.contains(target)) continue;
        addRelation(
          kind: _RelKind.dependency,
          targetName: targetName,
          label: label,
        );
      }
    }
  }

  if (type.superclass != null) {
    addRelation(
      kind: _RelKind.extendsRel,
      targetName: type.superclass!.name.lexeme,
      label: '',
    );
  }
  for (final mixinType in type.mixins) {
    addRelation(
      kind: _RelKind.implementsRel,
      targetName: mixinType.name.lexeme,
      label: 'with',
    );
  }
  for (final interfaceType in type.interfaces) {
    addRelation(
      kind: _RelKind.implementsRel,
      targetName: interfaceType.name.lexeme,
      label: 'implements',
    );
  }
  for (final constraint in type.constraints) {
    addRelation(
      kind: _RelKind.implementsRel,
      targetName: constraint.name.lexeme,
      label: 'on',
    );
  }
  final extended = type.extendedType;
  if (extended != null) {
    for (final targetName in _linkedTypeNames(extended)) {
      addRelation(
        kind: _RelKind.dependency,
        targetName: targetName,
        label: 'on',
      );
    }
  }
  return relations;
}

final class _Shape {
  const _Shape({required this.many, required this.nullable});

  final bool many;
  final bool nullable;
}

_Shape _collectionShape(TypeAnnotation annotation) {
  if (annotation is! NamedType) {
    return const _Shape(many: false, nullable: false);
  }
  return _Shape(
    many: _collectionTypes.contains(annotation.name.lexeme),
    nullable: annotation.question != null,
  );
}

String _safeLabel(String label) {
  if (RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$').hasMatch(label)) return label;
  return '';
}

String _renderClassDiagram(List<_TypeModel> types, List<_Relation> relations) {
  final buffer = StringBuffer('classDiagram\n');
  for (final type in types) {
    buffer.writeln('    class ${type.id} {');
    for (final stereotype in type.stereotypes) {
      buffer.writeln('        <<$stereotype>>');
    }
    for (final constant in type.enumConstants) {
      buffer.writeln('        ${_sanitizeMember(constant)}');
    }
    final fields = type.fields.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    for (final field in fields) {
      final typeText = field.type.isEmpty ? '' : '${field.type} ';
      final staticMark = field.isStatic ? r'$' : '';
      buffer.writeln(
        '        ${_sanitizeMember('+$typeText${field.name}$staticMark')}',
      );
    }
    final methods = type.methods.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    for (final method in methods) {
      buffer.writeln('        ${method.rendered}');
    }
    buffer.writeln('    }');
  }

  final unique = <String, _Relation>{};
  for (final relation in relations) {
    final key = [
      relation.kind.name,
      relation.source,
      relation.target,
      relation.label,
      relation.many.toString(),
      relation.nullable.toString(),
    ].join('|');
    unique.putIfAbsent(key, () => relation);
  }
  final sorted = unique.values.toList()
    ..sort((a, b) {
      final byKind = a.kind.index.compareTo(b.kind.index);
      if (byKind != 0) return byKind;
      final bySource = a.source.compareTo(b.source);
      if (bySource != 0) return bySource;
      final byTarget = a.target.compareTo(b.target);
      if (byTarget != 0) return byTarget;
      return a.label.compareTo(b.label);
    });
  if (sorted.isNotEmpty) buffer.writeln();
  for (final relation in sorted) {
    buffer.writeln('    ${_relationLine(relation)}');
  }
  return buffer.toString();
}

String _relationLine(_Relation relation) {
  final label = relation.label.isEmpty ? '' : ' : ${relation.label}';
  switch (relation.kind) {
    case _RelKind.extendsRel:
      return '${relation.target} <|-- ${relation.source}';
    case _RelKind.implementsRel:
      return '${relation.target} <|.. ${relation.source}$label';
    case _RelKind.composition:
      final right = relation.many
          ? '"*"'
          : (relation.nullable ? '"0..1"' : '"1"');
      return '${relation.source} "1" *-- $right ${relation.target}$label';
    case _RelKind.dependency:
      return '${relation.source} ..> ${relation.target}$label';
  }
}

List<String> omittedModelFiles(Directory root) {
  final covered = <String>{
    for (final group in groups.values)
      for (final file in group.files)
        if (file.path.startsWith('lib/core/models/')) file.path,
  };
  final directory = Directory('${root.path}/lib/core/models');
  final omitted =
      directory
          .listSync()
          .whereType<File>()
          .map((file) => relativePosix(root.path, file.path))
          .where((path) => path.endsWith('.dart'))
          .where((path) => !isGeneratedPath(path))
          .where((path) => !covered.contains(path))
          .toList()
        ..sort();
  return omitted;
}

String renderReadme(ImportGraph graph, List<RenderedDiagram> diagrams) {
  final buffer = StringBuffer()
    ..writeln(_generatedBanner)
    ..writeln()
    ..writeln('# Architektura')
    ..writeln()
    ..writeln(
      'Diagramy w tym katalogu opisują podział `lib/` i modele domenowe. '
      'Powstają ze skryptu `scripts/gen_class_diagrams.dart`, który czyta AST '
      'pakietem `analyzer`. Pomija `*.g.dart`, `*.freezed.dart` i '
      '`lib/l10n/generated`.',
    )
    ..writeln()
    ..writeln('## Przegląd pakietów')
    ..writeln()
    ..writeln(
      'Warstwy są numerowane od dołu. Pakiet z wyższym numerem może '
      'importować pakiet z niższym. Import w drugą stronę jest ruchem w górę.',
    )
    ..writeln()
    ..writeln('| Pakiet | Warstwa |')
    ..writeln('| --- | --- |');
  for (final package in overviewPackages) {
    buffer.writeln('| `${package.id}` | ${package.layer} |');
  }
  buffer
    ..writeln()
    ..writeln(
      'Czerwona krawędź (`linkStyle`, `#d1242f`) spełnia co najmniej jeden warunek:',
    )
    ..writeln()
    ..writeln('- oba końce leżą w tej samej silnie spójnej składowej (cykl),')
    ..writeln('- pakiet z niższej warstwy importuje pakiet z wyższej,')
    ..writeln(
      '- `app/screens` importuje pakiet inny niż `app/providers` i `core/models` '
      '(omija providers). `core/models` zostaje dozwolony, bo ekrany czytają '
      'modele bezpośrednio.',
    )
    ..writeln()
    ..writeln(
      'Liczba na strzałce to liczba dyrektyw `import` między pakietami, '
      'a nie liczba plików. Importy w obrębie jednego pakietu nie wchodzą do licznika.',
    )
    ..writeln()
    ..writeln('### Silnie spójne składowe')
    ..writeln();
  if (graph.cycles.isEmpty) {
    buffer.writeln('Brak cykli między pakietami z przeglądu.');
  } else {
    for (final cycle in graph.cycles) {
      buffer.writeln('- ${cycle.map((id) => '`$id`').join(', ')}');
    }
  }
  buffer
    ..writeln()
    ..writeln('### Krawędzie oczekiwane przez przegląd')
    ..writeln()
    ..writeln('| Krawędź | Importy | Status |')
    ..writeln('| --- | --- | --- |');
  for (final expected in expectedRedEdges) {
    final match = graph.edges.where(
      (edge) => edge.from == expected.$1 && edge.to == expected.$2,
    );
    if (match.isEmpty) {
      buffer.writeln(
        '| `${expected.$1}` → `${expected.$2}` | 0 | nie występuje |',
      );
    } else {
      final edge = match.single;
      final status = edge.red
          ? 'czerwona (${edge.reasons.join(', ')})'
          : 'jest, bez czerwieni';
      buffer.writeln(
        '| `${edge.from}` → `${edge.to}` | ${edge.count} | $status |',
      );
    }
  }

  final expectedKeys = expectedRedEdges
      .map((edge) => '${edge.$1}|${edge.$2}')
      .toSet();
  final extraRed = graph.edges.where((edge) {
    return edge.red && !expectedKeys.contains('${edge.from}|${edge.to}');
  });
  buffer
    ..writeln()
    ..writeln('### Pozostałe czerwone krawędzie')
    ..writeln();
  if (extraRed.isEmpty) {
    buffer.writeln('Brak czerwonych krawędzi poza listą oczekiwaną.');
  } else {
    for (final edge in extraRed) {
      buffer.writeln(
        '- `${edge.from}` → `${edge.to}` (${edge.count}, ${edge.reasons.join(', ')})',
      );
    }
  }

  buffer
    ..writeln()
    ..writeln('### Wszystkie krawędzie')
    ..writeln()
    ..writeln('| Z | Do | Importy | Oznaczenie | Przykład |')
    ..writeln('| --- | --- | --- | --- | --- |');
  for (final edge in graph.edges) {
    final mark = edge.red ? edge.reasons.join(', ') : 'zgodna z warstwą';
    buffer.writeln(
      '| `${edge.from}` | `${edge.to}` | ${edge.count} | $mark | '
      '`${edge.sample.replaceAll('|', '/')}` |',
    );
  }
  buffer
    ..writeln()
    ..writeln('```mermaid')
    ..writeln(renderFlowchart(graph).trimRight())
    ..writeln('```')
    ..writeln()
    ..writeln('## Legenda')
    ..writeln()
    ..writeln('### Przegląd')
    ..writeln()
    ..writeln(
      '- Strzałka `A --> B` oznacza, że pliki pakietu A importują pliki pakietu B.',
    )
    ..writeln('- Etykieta to liczba dyrektyw `import`.')
    ..writeln(
      '- Czerwień oznacza cykl, ruch w górę warstwy albo ominięcie providerów.',
    )
    ..writeln()
    ..writeln('### Diagram klas')
    ..writeln()
    ..writeln(
      '- `<<freezed>>` — klasa z adnotacją `@freezed` / `@Freezed` albo z `with _\$…`.',
    )
    ..writeln(
      '- `<<mixin>>`, `<<extension>>`, `<<enumeration>>`, `<<extensionType>>` — rodzaj deklaracji.',
    )
    ..writeln(
      '- `+` oznacza składową publiczną. `\$` na końcu linii oznacza składową statyczną.',
    )
    ..writeln(
      '- Typy generyczne są zapisane jako `List~Player~`. Znaki `<` i `>` rozbijają parser Mermaida na GitHubie.',
    )
    ..writeln('- `<|--` to `extends`.')
    ..writeln(
      '- `<|..` to `implements`, `with` albo ograniczenie `on` mixinu. Etykieta mówi, który z tych trzech przypadków.',
    )
    ..writeln(
      '- `*--` to kompozycja przez typ pola. `"*"` oznacza pole `List`, `Set`, `Iterable` albo `Map`. `"0..1"` oznacza pole nullable. `"1"` oznacza pole wymagane.',
    )
    ..writeln(
      '- `..>` to zależność przez parametr konstruktora albo typ `on` extension.',
    )
    ..writeln(
      '- Metody `copyWith`, `toJson`, `fromJson`, `==`, `hashCode` i `toString` są pominięte. Operatory też.',
    )
    ..writeln(
      '- Krawędź powstaje tylko wtedy, gdy oba typy są na tym samym diagramie. Inne typy zostają w sygnaturze składowej.',
    )
    ..writeln('- Stałe enuma, pola i metody są posortowane alfabetycznie.')
    ..writeln()
    ..writeln('```mermaid')
    ..writeln(_legendDiagram.trimRight())
    ..writeln('```')
    ..writeln()
    ..writeln('## Pliki i regeneracja')
    ..writeln()
    ..writeln('### Pliki')
    ..writeln()
    ..writeln(
      '- `docs/architecture/README.md` — ten przegląd, legenda i instrukcja.',
    )
    ..writeln(
      '- `docs/architecture/models.md` — diagramy klas `lib/core/models`.',
    )
    ..writeln(
      '- `scripts/gen_class_diagrams.dart` — generator i jedyna mapa grup plików (`groups`).',
    )
    ..writeln()
    ..writeln('### Diagramy')
    ..writeln();
  for (final diagram in diagrams) {
    buffer.writeln(
      '#### ${diagram.title} (`${diagram.id}`, ${diagram.typeCount} typów)',
    );
    buffer.writeln();
    buffer.writeln('Plik: `docs/architecture/${diagram.page}`.');
    buffer.writeln();
    for (final file in diagram.files) {
      buffer.writeln('- `$file`');
    }
    buffer.writeln();
  }
  buffer
    ..writeln('### Polecenie')
    ..writeln()
    ..writeln(
      'Z katalogu repozytorium, Dartem dostarczonym z Flutter 3.41.4 '
      '(nowszy SDK psuje `pub get` w tym repozytorium):',
    )
    ..writeln()
    ..writeln('```sh')
    ..writeln('dart run scripts/gen_class_diagrams.dart')
    ..writeln('```')
    ..writeln()
    ..writeln(
      'Skrypt nadpisuje markdown w `docs/architecture/`. Wynik jest '
      'deterministyczny: typy, składowe, relacje i krawędzie przeglądu są sortowane.',
    )
    ..writeln()
    ..writeln('### Kolejne strony')
    ..writeln()
    ..writeln(
      'Etap 2 dopisuje kolejne wpisy do mapy `groups` na górze skryptu. '
      'Wspólne pole `page` składa kilka diagramów w jeden plik:',
    )
    ..writeln()
    ..writeln('- `services.md` — `lib/core/services`')
    ..writeln(
      '- `simulation.md` — `lib/core/simulation` razem z `lib/core/tactics`',
    )
    ..writeln('- `ai.md` — `lib/core/ai`')
    ..writeln('- `balance.md` — uproszczony `lib/core/balance`')
    ..writeln('- `persistence.md` — `lib/data` oraz `lib/core/random`')
    ..writeln(
      '- `app.md` — providery z zależnościami od serwisów oraz lista '
      '„ekran → providery” bez widgetów',
    )
    ..writeln();
  return buffer.toString();
}

const _legendDiagram = '''
classDiagram
    class Parent
    class Child
    class Owner {
        <<freezed>>
        +List~Item~ items
    }
    class Item
    class Client
    class Extra {
        <<mixin>>
    }
    class OwnerX {
        <<extension>>
        +int size
    }
    Parent <|-- Child
    Extra <|.. Child : with
    Owner "1" *-- "*" Item : items
    Client ..> Parent : service
    OwnerX ..> Owner : on
''';

String renderFlowchart(ImportGraph graph) {
  final buffer = StringBuffer('flowchart LR\n');
  for (final package in overviewPackages) {
    buffer.writeln('    ${nodeId(package.id)}["${package.id}"]');
  }
  final red = <int>[];
  for (var i = 0; i < graph.edges.length; i++) {
    final edge = graph.edges[i];
    buffer.writeln(
      '    ${nodeId(edge.from)} -->|"${edge.count}"| ${nodeId(edge.to)}',
    );
    if (edge.red) red.add(i);
  }
  if (red.isNotEmpty) {
    buffer.writeln(
      '    linkStyle ${red.join(',')} stroke:#d1242f,stroke-width:2px',
    );
  }
  return buffer.toString();
}

String renderPage(
  String page,
  List<RenderedDiagram> diagrams,
  List<String> omitted,
) {
  final buffer = StringBuffer()
    ..writeln(_generatedBanner)
    ..writeln()
    ..writeln('# ${pageTitle(page)}')
    ..writeln()
    ..writeln(pageIntro(page, omitted).trimRight())
    ..writeln();
  for (final diagram in diagrams) {
    buffer
      ..writeln('## ${diagram.title}')
      ..writeln()
      ..writeln(diagram.description)
      ..writeln()
      ..writeln('Typów na diagramie: ${diagram.typeCount}.')
      ..writeln()
      ..writeln('```mermaid')
      ..writeln(diagram.mermaid.trimRight())
      ..writeln('```')
      ..writeln();
  }
  return buffer.toString();
}

String pageTitle(String page) {
  switch (page) {
    case 'models.md':
      return 'Modele domenowe';
    default:
      return page;
  }
}

String pageIntro(String page, List<String> omitted) {
  if (page != 'models.md') {
    return 'Diagramy wygenerowane z mapy `groups` w `scripts/gen_class_diagrams.dart`.';
  }
  final omittedList = omitted.map((path) => '- `$path`').join('\n');
  return '''
Cztery wycinki `lib/core/models`. Każdy diagram ma własny opis i trzyma się granicy około 40 typów.

`enums.dart` jest dzielony między diagramy polem `only` w mapie `groups`, bo jeden plik miesza wszystkie domeny. Formacje i role taktyczne (`Formation`, `GkRole` i pokrewne) zostają poza tymi czterema diagramami: sama `Formation` ma ponad dwadzieścia stałych.

Poza diagramami zostają pliki bez typu w tych wycinkach albo generatory i stan UI:

$omittedList
''';
}
