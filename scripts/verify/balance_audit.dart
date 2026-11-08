import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

class Numbers extends RecursiveAstVisitor<void> {
  Numbers(this.path, this.source, this.rows);
  final String path;
  final String source;
  final List<Map<String, Object?>> rows;
  void add(Literal node, {String kind = 'number'}) {
    AstNode value = node;
    if (node.parent is PrefixExpression) value = node.parent!;
    final before = source.substring(0, value.offset);
    final line = '\n'.allMatches(before).length + 1;
    final start = before.lastIndexOf('\n') + 1;
    final end = source.indexOf('\n', value.offset);
    var owner = '';
    AstNode? parent = node.parent;
    while (parent != null) {
      if (parent is MethodDeclaration) {
        owner = parent.name.lexeme;
        break;
      }
      if (parent is FunctionDeclaration) {
        owner = parent.name.lexeme;
        break;
      }
      if (parent is ConstructorDeclaration) {
        owner = 'constructor';
        break;
      }
      if (parent is VariableDeclaration) {
        owner = parent.name.lexeme;
        break;
      }
      parent = parent.parent;
    }
    final code = source.substring(start, end < 0 ? source.length : end).trim();
    AstNode context = value;
    for (
      AstNode? ancestor = value.parent;
      ancestor != null;
      ancestor = ancestor.parent
    ) {
      context = ancestor;
      if (ancestor is NamedExpression) {
        context = ancestor.parent?.parent ?? ancestor;
        break;
      }
      if (ancestor is Statement ||
          ancestor is FormalParameter ||
          ancestor is VariableDeclaration ||
          ancestor is MapLiteralEntry) {
        break;
      }
    }
    final fingerprint =
        '$path\n$owner\n${value.toSource()}\n${context.toSource()}';
    final key = sha256.convert(utf8.encode(fingerprint)).toString();
    rows.add({
      'key': key,
      'kind': kind,
      'context': context.toSource(),
      'file': path,
      'line': line,
      'column': value.offset - start + 1,
      'literal': value.toSource(),
      'owner': owner,
      'code': code,
    });
  }

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    if (node.parent is! Directive && RegExp(r'\d').hasMatch(node.value)) {
      add(node, kind: 'string');
    }
  }

  @override
  void visitStringInterpolation(StringInterpolation node) {
    if (node.elements.whereType<InterpolationString>().any(
      (part) => RegExp(r'\d').hasMatch(part.value),
    )) {
      add(node, kind: 'string');
    }
    super.visitStringInterpolation(node);
  }

  @override
  void visitIntegerLiteral(IntegerLiteral node) {
    add(node);
  }

  @override
  void visitDoubleLiteral(DoubleLiteral node) {
    add(node);
  }
}

Map<String, dynamic> inspectBalanceSources() {
  final registry = File('scripts/verify/balance_exceptions.json');
  final decisions = registry.existsSync()
      ? (jsonDecode(registry.readAsStringSync()) as Map<String, dynamic>)
      : <String, dynamic>{};
  final rows = <Map<String, Object?>>[];
  final files = <Map<String, Object?>>[];
  final all =
      Directory('lib').listSync(recursive: true).whereType<File>().toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  for (final file in all) {
    final path = file.path.replaceAll('\\', '/');
    if (!path.endsWith('.dart')) continue;
    final source = file.readAsStringSync();
    final parsed = parseString(content: source, throwIfDiagnostics: false);
    final start = rows.length;
    parsed.unit.accept(Numbers(path, source, rows));
    files.add({
      'file': path,
      'literals': rows.length - start,
      'generated':
          path.endsWith('.g.dart') ||
          path.endsWith('.freezed.dart') ||
          path.contains('/l10n/generated/'),
      'errors': parsed.errors.map((e) => e.toString()).toList(),
    });
  }
  for (final file in Directory(
    'lib/l10n',
  ).listSync().whereType<File>().where((f) => f.path.endsWith('.arb'))) {
    final path = file.path.replaceAll('\\', '/');
    final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    for (final entry in data.entries) {
      if (entry.key.startsWith('@') ||
          entry.value is! String ||
          !RegExp(r'\d').hasMatch(entry.value as String)) {
        continue;
      }
      final fingerprint = '$path\n${entry.key}\n${entry.value}';
      rows.add({
        'key': sha256.convert(utf8.encode(fingerprint)).toString(),
        'kind': 'arb',
        'file': path,
        'owner': entry.key,
        'literal': entry.value,
        'code': entry.value,
        'context': entry.value,
      });
    }
    files.add({'file': path, 'generated': false, 'errors': <String>[]});
  }
  for (final row in rows) {
    final path = row['file'] as String;
    final file = files.firstWhere((f) => f['file'] == path);
    row['review'] = file['generated'] == true
        ? 'generated'
        : path.startsWith('lib/core/balance/')
        ? 'balance'
        : decisions[row['key']] ?? 'unreviewed';
  }
  final pending = rows.where((r) => r['review'] == 'unreviewed').length;
  final errors = files.where((f) => (f['errors'] as List).isNotEmpty).length;
  final keys = rows.map((row) => row['key']).toSet();
  final stale = decisions.keys.where((key) => !keys.contains(key)).toList();
  return {
    'files': files,
    'rows': rows,
    'pending': pending,
    'errors': errors,
    'decisions': decisions.length,
    'stale': stale,
  };
}

void main(List<String> args) {
  final paths = args.where((a) => !a.startsWith('--')).toList();
  final output = paths.isEmpty
      ? 'build/balance-audit/i10-inventory.json'
      : paths.first;
  final report = inspectBalanceSources();
  File(output).parent.createSync(recursive: true);
  File(output).writeAsStringSync(jsonEncode(report));
  stdout.writeln(
    'Files: ${(report['files'] as List).length}; occurrences: ${(report['rows'] as List).length}; unreviewed: ${report['pending']}; parse errors: ${report['errors']}; stale decisions: ${(report['stale'] as List).length}',
  );
  if (args.contains('--check') &&
      (report['pending'] != 0 ||
          report['errors'] != 0 ||
          (report['stale'] as List).isNotEmpty)) {
    exitCode = 1;
  }
}
