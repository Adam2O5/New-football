/// Generates Mermaid architecture diagrams from the AST of `lib/`.
///
/// Run from the repository root with the Dart SDK shipped with Flutter 3.41.4:
/// `dart run scripts/gen_class_diagrams.dart`
library;

import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';

import 'class_diagram_logic.dart';

final class OverviewPackage {
  const OverviewPackage(this.id, this.directory, this.layer);

  final String id;
  final String directory;
  final int layer;
}

/// Higher layers may import lower layers. Importing a higher layer is
/// [EdgeKind.upLayer]. Screen imports that skip providers are
/// [EdgeKind.bypassProviders]. Entries in [allowedExceptions] stay grey.
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

const allowedExceptions = <AllowedException>[
  AllowedException(
    'data',
    'core/services',
    'adapter w data implementuje interfejs repozytorium zadeklarowany w core/services',
  ),
];

final _packagesById = {
  for (final package in overviewPackages) package.id: package,
};

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
    this.showMembers = true,
    this.includePrivate = false,
  });

  final String page;
  final String title;
  final String description;
  final List<DiagramFile> files;
  final bool showMembers;
  final bool includePrivate;
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
        'negocjacje — ich klasy są na kolejnych diagramach.',
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
        'diagramie kontraktów albo w `core/tactics`.',
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
        'draftu, RFA, oferty wymiany, stan draftu i prospect.',
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
        'skrzynka wiadomości oraz modyfikatory zawodnika i drużyny.',
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

final class PageInfo {
  const PageInfo({required this.title, required this.intro, this.omittedUnder});

  final String title;
  final String intro;

  /// When set, the page lists hand-written Dart files under this directory
  /// that no group includes.
  final String? omittedUnder;
}

const pages = <String, PageInfo>{
  'models.md': PageInfo(
    title: 'Modele domenowe',
    intro:
        'Cztery wycinki `lib/core/models`. Każdy diagram ma własny opis i '
        'trzyma się granicy około 40 typów.\n\n'
        '`enums.dart` jest dzielony między diagramy polem `only`, bo jeden '
        'plik miesza wszystkie domeny. Formacje i role taktyczne zostają poza '
        'tymi diagramami.\n\n'
        'Poza diagramami zostają pliki bez typu w tych wycinkach albo '
        'generatory i stan UI:',
    omittedUnder: 'lib/core/models',
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

const _maxTypesPerDiagram = 40;

const _generatedBanner =
    '<!-- Generated by scripts/gen_class_diagrams.dart. Do not edit by hand. -->';

void main() {
  final root = findRepoRoot();
  final library = _Library(root);
  final importGraph = _scanImports(root, library);
  final diagrams = [
    for (final entry in groups.entries)
      _renderGroup(library, entry.key, entry.value),
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
  for (final entry in byPage.entries) {
    File(
      '${outDir.path}/${entry.key}',
    ).writeAsStringSync(renderPage(root, entry.key, entry.value));
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
  final marked = importGraph.edges.where(
    (edge) => edge.kind != EdgeKind.normal,
  );
  stdout.writeln(
    'Imports: ${importGraph.edges.length} edges, '
    '${marked.length} marked, '
    'cycles: ${importGraph.cycles.map((cycle) => cycle.join('+')).join(' | ')}',
  );
  for (final edge in marked) {
    stdout.writeln(
      '${edge.kind.name} ${edge.from} -> ${edge.to} = ${edge.count}',
    );
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
    final directory = package.directory.substring('lib/'.length);
    if (path == directory || path.startsWith('$directory/')) return package.id;
  }
  return null;
}

int layerOf(String id) =>
    _packagesById[id]?.layer ?? (throw StateError('Unknown package $id'));

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
    required this.kind,
    this.note = '',
  });

  final String from;
  final String to;
  final int count;
  final String sample;
  final EdgeKind kind;
  final String note;
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

ImportGraph _scanImports(Directory root, _Library library) {
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
    final unit = library.unit(relative);
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

  final graph = <String, Set<String>>{
    for (final package in overviewPackages) package.id: <String>{},
  };
  for (final entry in counts.entries) {
    graph[entry.key.$1]!.add(entry.key.$2);
  }
  final components = stronglyConnected(graph.keys.toSet(), graph);
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

  final edges = [for (final key in keys) _classifiedEdge(key, counts[key]!)];
  return ImportGraph(edges, cycles);
}

ImportEdge _classifiedEdge((String, String) key, _ImportAccum accum) {
  final exception = allowedExceptions
      .where((item) => item.from == key.$1 && item.to == key.$2)
      .firstOrNull;
  final kind = classifyEdge(
    from: key.$1,
    to: key.$2,
    fromLayer: layerOf(key.$1),
    toLayer: layerOf(key.$2),
    isAllowedException: exception != null,
  );
  return ImportEdge(
    from: key.$1,
    to: key.$2,
    count: accum.count,
    sample: accum.sample ?? '',
    kind: kind,
    note: exception?.note ?? '',
  );
}

String relativePosix(String root, String absolute) {
  final prefix = root.endsWith('/') ? root : '$root/';
  final relative = absolute.startsWith(prefix)
      ? absolute.substring(prefix.length)
      : absolute;
  return relative.replaceAll('\\', '/');
}

final class _Library {
  _Library(this.root);

  final Directory root;
  final _units = <String, CompilationUnit>{};

  CompilationUnit unit(String relative) {
    return _units.putIfAbsent(relative, () {
      return parseString(
        content: File('${root.path}/$relative').readAsStringSync(),
        path: relative,
      ).unit;
    });
  }
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

RenderedDiagram _renderGroup(_Library library, String id, DiagramGroup group) {
  final types = <_TypeModel>[];
  final seenNames = <String, String>{};
  for (final file in group.files) {
    final source = File('${library.root.path}/${file.path}');
    if (!source.existsSync()) {
      throw StateError('Missing diagram file ${file.path}');
    }
    final unit = library.unit(file.path);
    final found = <String>{};
    for (final declaration in unit.declarations) {
      final model = _readDeclaration(declaration);
      if (model == null) continue;
      if (!group.includePrivate && model.simpleName.startsWith('_')) continue;
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
  final mermaid = _renderClassDiagram(
    types,
    relations,
    showMembers: group.showMembers,
  );
  _assertMermaidSafe(id, mermaid);
  return RenderedDiagram(
    id: id,
    page: group.page,
    title: group.title,
    description: _describe(group),
    files: [for (final file in group.files) file.path],
    typeCount: types.length,
    mermaid: mermaid,
  );
}

void _assertMermaidSafe(String id, String mermaid) {
  final problem = mermaidProblem(mermaid);
  if (problem != null) throw StateError('$id: $problem');
}

String _describe(DiagramGroup group) {
  final picked = <String>[
    for (final file in group.files)
      if (file.only != null) ...file.only!,
  ]..sort();
  if (picked.isEmpty) return group.description;
  final names = picked.map((name) => '`$name`').join(', ');
  return '${group.description} Z `enums.dart`: $names.';
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
  if (model.freezed) {
    for (final constructor in model.constructors) {
      if (constructor.factoryKeyword == null || constructor.name != null) {
        continue;
      }
      for (final parameter in constructor.parameters.parameters) {
        _addParameterField(model, parameter);
      }
    }
  }
  _fillFieldFormalTypes(model);
}

void _fillFieldFormalTypes(_TypeModel model) {
  for (final constructor in model.constructors) {
    for (final parameter in constructor.parameters.parameters) {
      final inner = _unwrapParameter(parameter);
      if (inner is! FieldFormalParameter || inner.type == null) continue;
      final field = model.fields[inner.name.lexeme];
      if (field != null && field.type.isEmpty) {
        field.type = _renderType(inner.type!);
        field.sourceType ??= inner.type;
      }
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
  if (method.isOperator || method.isSetter) return;
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
  model.methods[name] = _Member(name, sanitizeMember(buffer.toString()));
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
    if (piece.isNotEmpty) parts.add(sanitizeMember(piece));
  }
  return limitParameterList(parts);
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

String _renderClassDiagram(
  List<_TypeModel> types,
  List<_Relation> relations, {
  required bool showMembers,
}) {
  final buffer = StringBuffer('classDiagram\n');
  for (final type in types) {
    buffer.writeln('    class ${type.id} {');
    for (final stereotype in type.stereotypes) {
      buffer.writeln('        <<$stereotype>>');
    }
    if (showMembers) {
      for (final constant in type.enumConstants) {
        buffer.writeln('        ${sanitizeMember(constant)}');
      }
      final fields = type.fields.values.toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      for (final field in fields) {
        final typeText = field.type.isEmpty ? '' : '${field.type} ';
        final staticMark = field.isStatic ? r'$' : '';
        buffer.writeln(
          '        ${sanitizeMember('+$typeText${field.name}$staticMark')}',
        );
      }
      final methods = type.methods.values.toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      for (final method in methods) {
        buffer.writeln('        ${method.rendered}');
      }
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

List<String> omittedFiles(Directory root, String relativeDirectory) {
  final prefix = relativeDirectory.endsWith('/')
      ? relativeDirectory
      : '$relativeDirectory/';
  final covered = <String>{
    for (final group in groups.values)
      for (final file in group.files)
        if (file.path.startsWith(prefix)) file.path,
  };
  final directory = Directory('${root.path}/$relativeDirectory');
  if (!directory.existsSync()) return const [];
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
    ..write(_renderOverview(graph))
    ..write(_renderLegend())
    ..write(_renderFileIndex(diagrams));
  return buffer.toString();
}

String _renderOverview(ImportGraph graph) {
  final buffer = StringBuffer()
    ..writeln('# Architektura')
    ..writeln()
    ..writeln(
      'Diagramy w tym katalogu powstają ze skryptu '
      '`scripts/gen_class_diagrams.dart`, który czyta AST pakietem `analyzer`. '
      'Pomija `*.g.dart`, `*.freezed.dart` i `lib/l10n/generated`.',
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
    ..writeln('Kolor krawędzi pochodzi z `EdgeKind`:')
    ..writeln();
  for (final kind in EdgeKind.values) {
    buffer.writeln('- ${edgeKindLegend[kind]}');
  }
  buffer
    ..writeln()
    ..writeln(
      'Liczba na strzałce to liczba dyrektyw `import`. `export` oraz importy '
      'warunkowe nie wchodzą do licznika. Import wewnątrz jednego pakietu też nie.',
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
  final marked = graph.edges.where((edge) => edge.kind != EdgeKind.normal);
  buffer
    ..writeln()
    ..writeln('### Oznaczone krawędzie')
    ..writeln();
  if (marked.isEmpty) {
    buffer.writeln('Wszystkie krawędzie są zgodne z warstwą.');
  } else {
    for (final edge in marked) {
      final note = edge.note.isEmpty ? '' : ' — ${edge.note}';
      buffer.writeln(
        '- `${edge.from}` → `${edge.to}` (${edge.count}, '
        '${edgeKindLabel[edge.kind]})$note',
      );
    }
  }
  buffer
    ..writeln()
    ..writeln('```mermaid')
    ..writeln(renderFlowchart(graph).trimRight())
    ..writeln('```')
    ..writeln()
    ..writeln('<details>')
    ..writeln('<summary>Wszystkie krawędzie</summary>')
    ..writeln()
    ..writeln('| Z | Do | Importy | Oznaczenie | Przykład |')
    ..writeln('| --- | --- | --- | --- | --- |');
  for (final edge in graph.edges) {
    buffer.writeln(
      '| `${edge.from}` | `${edge.to}` | ${edge.count} | '
      '${edgeKindLabel[edge.kind]} | '
      '`${edge.sample.replaceAll('|', '/')}` |',
    );
  }
  buffer
    ..writeln()
    ..writeln('</details>')
    ..writeln();
  return buffer.toString();
}

String _renderLegend() {
  final buffer = StringBuffer()
    ..writeln('## Legenda')
    ..writeln()
    ..writeln('### Przegląd')
    ..writeln()
    ..writeln(
      '- Strzałka `A --> B` oznacza, że pliki pakietu A importują pliki pakietu B.',
    )
    ..writeln('- Etykieta to liczba dyrektyw `import`.')
    ..writeln(
      '- Ramka `subgraph` z etykietą `cykl` grupuje silnie spójną składową. '
      'Krawędzie w dół wewnątrz ramki zostają w zwykłym stylu.',
    );
  for (final kind in EdgeKind.values) {
    if (kind == EdgeKind.normal) continue;
    buffer.writeln('- ${edgeKindLegend[kind]}');
  }
  for (final exception in allowedExceptions) {
    buffer.writeln(
      '- Wyjątek `${exception.from}` → `${exception.to}`: ${exception.note}.',
    );
  }
  buffer
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
      '- Pominięte są operatory oraz metody `copyWith`, `toJson`, `fromJson`, `hashCode` i `toString`.',
    )
    ..writeln(
      '- Pole bez adnotacji typu jest zapisane samą nazwą, na przykład `+currentVersion\$`.',
    )
    ..writeln(
      '- Krawędź powstaje tylko wtedy, gdy oba typy są na tym samym diagramie.',
    )
    ..writeln('- Stałe enuma, pola i metody są posortowane alfabetycznie.')
    ..writeln()
    ..writeln('```mermaid')
    ..writeln(_legendDiagram.trimRight())
    ..writeln('```')
    ..writeln();
  return buffer.toString();
}

String _renderFileIndex(List<RenderedDiagram> diagrams) {
  final buffer = StringBuffer()
    ..writeln('## Pliki i regeneracja')
    ..writeln()
    ..writeln('### Pliki')
    ..writeln()
    ..writeln(
      '- `docs/architecture/README.md` — ten przegląd, legenda i instrukcja.',
    )
    ..writeln(
      '- `scripts/gen_class_diagrams.dart` — generator. Mapa grup to `groups`, mapa stron to `pages`.',
    )
    ..writeln(
      '- `scripts/class_diagram_logic.dart` — czyste funkcje używane przez generator i testy.',
    );
  for (final entry in pages.entries) {
    buffer.writeln(
      '- `docs/architecture/${entry.key}` — ${entry.value.title}.',
    );
  }
  buffer
    ..writeln()
    ..writeln('### Diagramy')
    ..writeln();
  for (final diagram in diagrams) {
    buffer
      ..writeln(
        '#### ${diagram.title} (`${diagram.id}`, ${polishTyp(diagram.typeCount)})',
      )
      ..writeln()
      ..writeln('Plik: `docs/architecture/${diagram.page}`.')
      ..writeln();
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
  final inCycle = graph.cycles.expand((cycle) => cycle).toSet();
  for (var i = 0; i < graph.cycles.length; i++) {
    final cycle = graph.cycles[i];
    final label = graph.cycles.length == 1 ? 'cykl' : 'cykl ${i + 1}';
    buffer.writeln('    subgraph cycle_${i + 1} ["$label"]');
    for (final package in overviewPackages) {
      if (!cycle.contains(package.id)) continue;
      buffer.writeln('        ${nodeId(package.id)}["${package.id}"]');
    }
    buffer.writeln('    end');
  }
  for (final package in overviewPackages) {
    if (inCycle.contains(package.id)) continue;
    buffer.writeln('    ${nodeId(package.id)}["${package.id}"]');
  }
  final indexes = <EdgeKind, List<int>>{
    for (final kind in EdgeKind.values)
      if (kind != EdgeKind.normal) kind: <int>[],
  };
  for (var i = 0; i < graph.edges.length; i++) {
    final edge = graph.edges[i];
    buffer.writeln(
      '    ${nodeId(edge.from)} -->|"${edgeCountLabel(edge.count, edge.kind)}"| ${nodeId(edge.to)}',
    );
    indexes[edge.kind]?.add(i);
  }
  for (final kind in EdgeKind.values) {
    final style = edgeKindStyle[kind];
    final ids = indexes[kind];
    if (style == null || ids == null || ids.isEmpty) continue;
    buffer.writeln('    linkStyle ${ids.join(',')} $style');
  }
  return buffer.toString();
}

String renderPage(Directory root, String page, List<RenderedDiagram> diagrams) {
  final info = pages[page];
  if (info == null) {
    throw StateError('Add $page to the pages map before generating it.');
  }
  final buffer = StringBuffer()
    ..writeln(_generatedBanner)
    ..writeln()
    ..writeln('# ${info.title}')
    ..writeln()
    ..writeln(info.intro.trimRight());
  final omittedRoot = info.omittedUnder;
  if (omittedRoot != null) {
    final omitted = omittedFiles(root, omittedRoot);
    buffer.writeln();
    if (omitted.isEmpty) {
      buffer.writeln('Każdy ręczny plik z `$omittedRoot` jest na diagramie.');
    } else {
      for (final path in omitted) {
        buffer.writeln('- `$path`');
      }
    }
  }
  buffer.writeln();
  for (final diagram in diagrams) {
    buffer
      ..writeln('## ${diagram.title}')
      ..writeln()
      ..writeln(diagram.description)
      ..writeln()
      ..writeln('${_capitalize(polishTyp(diagram.typeCount))} na diagramie.')
      ..writeln()
      ..writeln('```mermaid')
      ..writeln(diagram.mermaid.trimRight())
      ..writeln('```')
      ..writeln();
  }
  return buffer.toString();
}

String _capitalize(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1);
}
