/// Pure helpers for the architecture-diagram generator.
///
/// These functions take synthetic inputs only. The generator script imports
/// them; tests cover them without reading `lib/`.
library;

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
