/// Pure helpers for the architecture-diagram generator.
///
/// These functions take synthetic inputs only. The generator script imports
/// them; tests cover them without reading `lib/`.
library;

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

enum EdgeKind { normal, upLayer, bypassProviders, allowedException }

/// Mermaid `linkStyle` payload for each non-default edge kind.
const edgeKindStyle = <EdgeKind, String>{
  EdgeKind.upLayer: 'stroke:#d1242f,stroke-width:2px',
  EdgeKind.bypassProviders:
      'stroke:#d1242f,stroke-width:2px,stroke-dasharray:6 4',
  EdgeKind.allowedException: 'stroke:#8c959f,stroke-width:2px',
};

/// Short label used in the edge table.
const edgeKindLabel = <EdgeKind, String>{
  EdgeKind.normal: 'zgodna z warstwą',
  EdgeKind.upLayer: 'warstwa w górę',
  EdgeKind.bypassProviders: 'omija providers',
  EdgeKind.allowedException: 'dozwolony wyjątek',
};

/// Legend sentence generated from the same classification as the diagram.
const edgeKindLegend = <EdgeKind, String>{
  EdgeKind.normal:
      'Zwykła krawędź: import w dół warstwy albo w obrębie tej samej warstwy.',
  EdgeKind.upLayer:
      'Ciągła czerwień: pakiet z niższej warstwy importuje pakiet z wyższej.',
  EdgeKind.bypassProviders:
      'Przerywana czerwień: `app/screens` importuje pakiet inny niż `app/providers` i `core/models`.',
  EdgeKind.allowedException:
      'Szara krawędź: dozwolony wyjątek z listy `allowedExceptions`.',
};

final class AllowedException {
  const AllowedException(this.from, this.to, this.note);

  final String from;
  final String to;
  final String note;
}

const maxParameterChars = 96;

EdgeKind classifyEdge({
  required String from,
  required String to,
  required int fromLayer,
  required int toLayer,
  required bool isAllowedException,
}) {
  if (isAllowedException) return EdgeKind.allowedException;
  if (fromLayer < toLayer) return EdgeKind.upLayer;
  if (from == 'app/screens' && to != 'app/providers' && to != 'core/models') {
    return EdgeKind.bypassProviders;
  }
  return EdgeKind.normal;
}

String edgeCountLabel(int count, EdgeKind kind) {
  if (kind == EdgeKind.allowedException) return '$count (wyjątek)';
  return '$count';
}

/// `1 typ`, `2 typy`, `5 typów`, `12 typów`, `22 typy`.
String polishTyp(int count) =>
    polishCount(count, one: 'typ', few: 'typy', many: 'typów');

String polishCount(
  int count, {
  required String one,
  required String few,
  required String many,
}) {
  final noun = _polishNoun(count, one: one, few: few, many: many);
  return '$count $noun';
}

String _polishNoun(
  int count, {
  required String one,
  required String few,
  required String many,
}) {
  final mod10 = count % 10;
  final mod100 = count % 100;
  if (count == 1) return one;
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return few;
  return many;
}

/// Keeps whole parameters. A cut never lands inside `List~Player~`.
String limitParameterList(List<String> parts) {
  final kept = <String>[];
  for (final part in parts) {
    final candidate = [...kept, part].join(', ');
    if (candidate.length > maxParameterChars) {
      kept.add('...');
      break;
    }
    kept.add(part);
  }
  return kept.join(', ');
}

String sanitizeMember(String input) {
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

/// Returns a problem description when [diagram] would break Mermaid.
String? mermaidProblem(String diagram) {
  final stripped = diagram
      .replaceAll(RegExp(r'<<[A-Za-z]+>>'), '')
      .replaceAll('<|--', '')
      .replaceAll('<|..', '')
      .replaceAll('-->', '')
      .replaceAll('..>', '');
  if (stripped.contains('<') || stripped.contains('>')) {
    return 'raw angle brackets';
  }
  final lines = diagram.split('\n');
  for (var i = 0; i < lines.length; i++) {
    if (!tildesBalanced(lines[i])) {
      return 'unbalanced ~ on line ${i + 1}';
    }
  }
  return null;
}

bool tildesBalanced(String line) => '~'.allMatches(line).length.isEven;

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

/// Kosaraju. Neighbours are visited in sorted order so the finish order is stable.
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

enum RefKind { watch, read }

final class RefUse {
  const RefUse({
    required this.kind,
    required this.provider,
    required this.line,
    required this.snippet,
    required this.offset,
  });

  /// Null when the argument is not a statically named provider.
  final RefKind kind;
  final String? provider;
  final int line;
  final String snippet;
  final int offset;

  bool get resolved => provider != null;
}

final class ProviderNode {
  const ProviderNode({
    required this.name,
    required this.exposedType,
    required this.file,
    required this.unresolved,
  });

  final String name;
  final String? exposedType;
  final String file;
  final bool unresolved;
}

final class ProviderEdge {
  const ProviderEdge({
    required this.from,
    required this.to,
    required this.kind,
  });

  final String from;
  final String to;
  final RefKind kind;
}

final class UnresolvedSpot {
  const UnresolvedSpot({
    required this.owner,
    required this.file,
    required this.line,
    required this.snippet,
  });

  final String owner;
  final String file;
  final int line;
  final String snippet;
}

final class ProviderDiagramData {
  const ProviderDiagramData({
    required this.nodes,
    required this.edges,
    required this.unresolved,
  });

  final List<ProviderNode> nodes;
  final List<ProviderEdge> edges;
  final List<UnresolvedSpot> unresolved;
}

/// Every `ref.watch` / `ref.read` in [source]. The receiver may be named
/// `ref` or `_ref`. `.notifier`, `.future` and `.select(...)` collapse to
/// the provider identifier. Anything else stays unresolved (`provider == null`).
List<RefUse> extractRefUses(String source) {
  final unit = parseString(content: source, path: 'snippet.dart').unit;
  final uses = <RefUse>[];
  unit.accept(_RefUseVisitor(source, uses));
  uses.sort((a, b) {
    final byOffset = a.offset.compareTo(b.offset);
    if (byOffset != 0) return byOffset;
    return a.kind.index.compareTo(b.kind.index);
  });
  return uses;
}

/// Providers declared in [sources] (path → source) and the watch/read edges
/// between them. A provider that returns `Foo(ref)` also contributes the
/// `ref` uses inside `Foo` and its `with` mixins, when those declarations
/// are in [sources].
ProviderDiagramData analyzeProviderSources(Map<String, String> sources) {
  final units = <String, CompilationUnit>{};
  for (final entry in sources.entries) {
    units[entry.key] = parseString(content: entry.value, path: entry.key).unit;
  }
  final declarations = <String, _TypeDecl>{};
  for (final entry in units.entries) {
    for (final declaration in entry.value.declarations) {
      if (declaration is ClassDeclaration) {
        declarations[declaration.namePart.typeName.lexeme] = _TypeDecl(
          declaration.namePart.typeName.lexeme,
          entry.key,
          declaration.offset,
          declaration.end,
          declaration.withClause?.mixinTypes
                  .map((type) => type.name.lexeme)
                  .toList() ??
              const [],
        );
      } else if (declaration is MixinDeclaration) {
        declarations[declaration.name.lexeme] = _TypeDecl(
          declaration.name.lexeme,
          entry.key,
          declaration.offset,
          declaration.end,
          const [],
        );
      }
    }
  }

  final found = <_FoundProvider>[];
  for (final entry in units.entries) {
    for (final declaration in entry.value.declarations) {
      if (declaration is! TopLevelVariableDeclaration) continue;
      for (final variable in declaration.variables.variables) {
        final name = variable.name.lexeme;
        if (!name.endsWith('Provider') || name.startsWith('_')) continue;
        found.add(
          _FoundProvider(
            name: name,
            file: entry.key,
            start: variable.offset,
            end: variable.end,
            exposedType: _exposedType(variable),
            implementation: _implementationClass(variable.initializer),
          ),
        );
      }
    }
  }
  final byName = {for (final provider in found) provider.name: provider};
  for (final provider in found) {
    if (provider.exposedType != null) continue;
    final alias = _aliasTarget(sources[provider.file]!, provider);
    final target = alias == null ? null : byName[alias];
    if (target != null) provider.exposedType = target.exposedType;
  }

  final nodes = <ProviderNode>[];
  final edgeKeys = <String, ProviderEdge>{};
  final unresolved = <UnresolvedSpot>[];
  for (final provider in found) {
    final uses = <RefUse>[];
    final ownSource = sources[provider.file]!;
    for (final use in extractRefUses(ownSource)) {
      if (use.offset >= provider.start && use.offset < provider.end) {
        uses.add(use);
      }
    }
    final implementation = provider.implementation;
    if (implementation != null) {
      final seen = <String>{};
      void collect(String typeName) {
        if (!seen.add(typeName)) return;
        final declaration = declarations[typeName];
        if (declaration == null) return;
        final source = sources[declaration.file]!;
        for (final use in extractRefUses(source)) {
          if (use.offset >= declaration.start && use.offset < declaration.end) {
            uses.add(use);
          }
        }
        for (final mixinName in declaration.mixins) {
          collect(mixinName);
        }
      }

      collect(implementation);
    }
    var hasUnresolved = false;
    for (final use in uses) {
      if (!use.resolved) {
        hasUnresolved = true;
        unresolved.add(
          UnresolvedSpot(
            owner: provider.name,
            file: provider.file,
            line: use.line,
            snippet: use.snippet,
          ),
        );
        continue;
      }
      edgeKeys['${provider.name}|${use.provider}|${use.kind.name}'] =
          ProviderEdge(from: provider.name, to: use.provider!, kind: use.kind);
    }
    nodes.add(
      ProviderNode(
        name: provider.name,
        exposedType: provider.exposedType,
        file: provider.file,
        unresolved: hasUnresolved,
      ),
    );
  }
  nodes.sort((a, b) => a.name.compareTo(b.name));
  final edges = edgeKeys.values.toList()
    ..sort((a, b) {
      final byFrom = a.from.compareTo(b.from);
      if (byFrom != 0) return byFrom;
      final byKind = a.kind.index.compareTo(b.kind.index);
      if (byKind != 0) return byKind;
      return a.to.compareTo(b.to);
    });
  unresolved.sort((a, b) {
    final byOwner = a.owner.compareTo(b.owner);
    if (byOwner != 0) return byOwner;
    final byFile = a.file.compareTo(b.file);
    if (byFile != 0) return byFile;
    final byLine = a.line.compareTo(b.line);
    if (byLine != 0) return byLine;
    return a.snippet.compareTo(b.snippet);
  });
  return ProviderDiagramData(
    nodes: nodes,
    edges: edges,
    unresolved: unresolved,
  );
}

final class _FoundProvider {
  _FoundProvider({
    required this.name,
    required this.file,
    required this.start,
    required this.end,
    required this.exposedType,
    required this.implementation,
  });

  final String name;
  final String file;
  final int start;
  final int end;
  String? exposedType;
  final String? implementation;
}

final class _TypeDecl {
  const _TypeDecl(this.name, this.file, this.start, this.end, this.mixins);

  final String name;
  final String file;
  final int start;
  final int end;
  final List<String> mixins;
}

final class _RefUseVisitor extends RecursiveAstVisitor<void> {
  _RefUseVisitor(this.source, this.uses);

  final String source;
  final List<RefUse> uses;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final name = node.methodName.name;
    final target = node.target;
    if ((name == 'watch' || name == 'read') && target is SimpleIdentifier) {
      final argument = _firstPositional(node.argumentList);
      final provider = argument == null ? null : providerNameOf(argument);
      final snippet = argument == null ? name : _snippet(argument.toSource());
      uses.add(
        RefUse(
          kind: name == 'watch' ? RefKind.watch : RefKind.read,
          provider: provider,
          line: _lineOf(source, node.offset),
          snippet: snippet,
          offset: node.offset,
        ),
      );
    }
    super.visitMethodInvocation(node);
  }
}

String? providerNameOf(Expression expression) {
  final node = _unwrap(expression);
  if (node is SimpleIdentifier) {
    return node.name.endsWith('Provider') ? node.name : null;
  }
  if (node is PrefixedIdentifier) {
    if (_isModifier(node.identifier.name) &&
        node.prefix.name.endsWith('Provider')) {
      return node.prefix.name;
    }
    return null;
  }
  if (node is PropertyAccess) {
    if (_isModifier(node.propertyName.name) && node.target != null) {
      return providerNameOf(node.target!);
    }
    return null;
  }
  if (node is MethodInvocation) {
    if (node.methodName.name == 'select' && node.target != null) {
      return providerNameOf(node.target!);
    }
    if (node.methodName.name.endsWith('Provider')) return node.methodName.name;
    return null;
  }
  return null;
}

bool _isModifier(String name) => name == 'notifier' || name == 'future';

Expression _unwrap(Expression expression) {
  var current = expression;
  while (current is ParenthesizedExpression) {
    current = current.expression;
  }
  return current;
}

Expression? _firstPositional(ArgumentList arguments) {
  for (final argument in arguments.arguments) {
    if (argument is NamedExpression) continue;
    return argument;
  }
  return null;
}

int _lineOf(String source, int offset) =>
    '\n'.allMatches(source.substring(0, offset)).length + 1;

String _snippet(String source) {
  final flat = source.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (flat.length <= 72) return flat;
  return '${flat.substring(0, 69)}...';
}

String? _exposedType(VariableDeclaration variable) {
  final initializer = variable.initializer;
  if (initializer == null) return null;
  final invocation = _unwrap(initializer);
  TypeArgumentList? typeArguments;
  String? base;
  FunctionExpression? callback;
  if (invocation is MethodInvocation) {
    typeArguments = invocation.typeArguments;
    base = _baseName(invocation.target, invocation.methodName.name);
    callback = _callback(invocation.argumentList);
  } else if (invocation is InstanceCreationExpression) {
    typeArguments = invocation.constructorName.type.typeArguments;
    base = invocation.constructorName.type.name.lexeme;
    callback = _callback(invocation.argumentList);
  } else {
    return null;
  }
  final rendered = _typeArgument(base, typeArguments);
  if (rendered != null) return rendered;
  return callback == null ? null : _constructedReturnType(callback);
}

String? _baseName(Expression? target, String method) {
  if (target is SimpleIdentifier) return target.name;
  if (target is PrefixedIdentifier) return target.identifier.name;
  return method;
}

String? _typeArgument(String? base, TypeArgumentList? arguments) {
  if (arguments == null || arguments.arguments.isEmpty) return null;
  final index = base == 'StateNotifierProvider' || base == 'NotifierProvider'
      ? 1
      : 0;
  if (index >= arguments.arguments.length) return null;
  return _renderTypeArgument(arguments.arguments[index]);
}

String? _renderTypeArgument(TypeAnnotation type) {
  if (type is! NamedType) return null;
  final nullable = type.question == null ? '' : '?';
  final args = type.typeArguments?.arguments;
  if (args == null || args.isEmpty) return '${type.name.lexeme}$nullable';
  final inner = args.map(_renderTypeArgument).join(', ');
  return '${type.name.lexeme}~$inner~$nullable';
}

FunctionExpression? _callback(ArgumentList arguments) {
  final first = _firstPositional(arguments);
  final unwrapped = first == null ? null : _unwrap(first);
  return unwrapped is FunctionExpression ? unwrapped : null;
}

String? _constructedReturnType(FunctionExpression function) {
  final body = function.body;
  if (body is ExpressionFunctionBody) {
    return _constructorTypeName(body.expression);
  }
  if (body is! BlockFunctionBody) return null;
  final names = <String>{};
  for (final statement in body.block.statements) {
    if (statement is! ReturnStatement || statement.expression == null) {
      continue;
    }
    final expression = statement.expression!;
    if (_unwrap(expression) is NullLiteral) continue;
    final name = _constructorTypeName(expression);
    if (name == null) return null;
    names.add(name);
  }
  if (names.length != 1) return null;
  return names.single;
}

String? _constructorTypeName(Expression expression) {
  final node = _unwrap(expression);
  if (node is InstanceCreationExpression) {
    return node.constructorName.type.name.lexeme;
  }
  if (node is MethodInvocation &&
      node.target == null &&
      _startsUpper(node.methodName.name)) {
    return node.methodName.name;
  }
  return null;
}

String? _implementationClass(Expression? initializer) {
  if (initializer == null) return null;
  final invocation = _unwrap(initializer);
  final ArgumentList? arguments = switch (invocation) {
    MethodInvocation() => invocation.argumentList,
    InstanceCreationExpression() => invocation.argumentList,
    _ => null,
  };
  final callback = arguments == null ? null : _callback(arguments);
  if (callback == null) return null;
  final body = callback.body;
  if (body is ExpressionFunctionBody) {
    return _constructorPassingRef(body.expression);
  }
  if (body is! BlockFunctionBody) return null;
  String? found;
  for (final statement in body.block.statements) {
    if (statement is! ReturnStatement || statement.expression == null) {
      continue;
    }
    if (_unwrap(statement.expression!) is NullLiteral) continue;
    final name = _constructorPassingRef(statement.expression!);
    if (name == null) return null;
    if (found != null && found != name) return null;
    found = name;
  }
  return found;
}

String? _constructorPassingRef(Expression expression) {
  final node = _unwrap(expression);
  ArgumentList? arguments;
  String? name;
  if (node is InstanceCreationExpression) {
    name = node.constructorName.type.name.lexeme;
    arguments = node.argumentList;
  } else if (node is MethodInvocation &&
      node.target == null &&
      _startsUpper(node.methodName.name)) {
    name = node.methodName.name;
    arguments = node.argumentList;
  }
  if (name == null || arguments == null || !_passesRef(arguments)) return null;
  return name;
}

bool _passesRef(ArgumentList arguments) {
  for (final argument in arguments.arguments) {
    final expression = argument is NamedExpression
        ? argument.expression
        : argument;
    final node = _unwrap(expression);
    if (node is SimpleIdentifier &&
        (node.name == 'ref' || node.name == '_ref')) {
      return true;
    }
  }
  return false;
}

bool _startsUpper(String name) {
  if (name.isEmpty) return false;
  final char = name[0];
  return char.toUpperCase() == char && char.toLowerCase() != char;
}

String? _aliasTarget(String source, _FoundProvider provider) {
  final unit = parseString(content: source, path: provider.file).unit;
  for (final declaration in unit.declarations) {
    if (declaration is! TopLevelVariableDeclaration) continue;
    for (final variable in declaration.variables.variables) {
      if (variable.name.lexeme != provider.name) continue;
      final initializer = variable.initializer;
      if (initializer is SimpleIdentifier &&
          initializer.name.endsWith('Provider')) {
        return initializer.name;
      }
    }
  }
  return null;
}
