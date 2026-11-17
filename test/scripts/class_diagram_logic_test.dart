@Tags(['unit'])
library;

import 'package:flutter_test/flutter_test.dart';

import '../../scripts/class_diagram_logic.dart';

void main() {
  group('resolveImport', () {
    test('resolves a package import and ignores other packages', () {
      expect(
        resolveImport(
          'lib/core/services/day_simulator.dart',
          'package:new_football/core/models/player.dart',
        ),
        'core/models/player.dart',
      );
      expect(
        resolveImport(
          'lib/core/services/day_simulator.dart',
          'package:flutter/widgets.dart',
        ),
        isNull,
      );
      expect(resolveImport('lib/core/models/player.dart', 'dart:core'), isNull);
    });

    test('resolves a relative import that walks up', () {
      expect(
        normalizePosix('lib/core/services/../models/player.dart'),
        'lib/core/models/player.dart',
      );
      expect(
        resolveImport(
          'lib/core/services/day_simulator.dart',
          '../models/player.dart',
        ),
        'lib/core/models/player.dart',
      );
      expect(
        resolveImport('lib/data/save_repository.dart', 'save_recovery.dart'),
        'lib/data/save_recovery.dart',
      );
    });
  });

  group('stronglyConnected', () {
    test('finds a two-node cycle and leaves a one-way edge outside it', () {
      const nodes = {'a', 'b', 'c'};
      const graph = {
        'a': {'b'},
        'b': {'a'},
        'c': {'a'},
      };
      final cycles = [
        for (final component in stronglyConnected(nodes, graph))
          if (component.length > 1) (component.toList()..sort()),
      ];
      expect(cycles, [
        ['a', 'b'],
      ]);
    });

    test('finds one component on a three-node cycle', () {
      const nodes = {'a', 'b', 'c'};
      const graph = {
        'a': {'b'},
        'b': {'c'},
        'c': {'a'},
      };
      final big = stronglyConnected(nodes, graph).single;
      expect(big, {'a', 'b', 'c'});
    });
  });

  group('classifyEdge', () {
    test('marks up-layer, bypass, allowed exception and downward edges', () {
      expect(
        classifyEdge(
          from: 'core/models',
          to: 'core/services',
          fromLayer: 0,
          toLayer: 5,
          isAllowedException: false,
        ),
        EdgeKind.upLayer,
      );
      expect(
        classifyEdge(
          from: 'core/services',
          to: 'core/ai',
          fromLayer: 5,
          toLayer: 3,
          isAllowedException: false,
        ),
        EdgeKind.normal,
      );
      expect(
        classifyEdge(
          from: 'app/screens',
          to: 'core/ai',
          fromLayer: 7,
          toLayer: 3,
          isAllowedException: false,
        ),
        EdgeKind.bypassProviders,
      );
      expect(
        classifyEdge(
          from: 'app/screens',
          to: 'core/models',
          fromLayer: 7,
          toLayer: 0,
          isAllowedException: false,
        ),
        EdgeKind.normal,
      );
      expect(
        classifyEdge(
          from: 'data',
          to: 'core/services',
          fromLayer: 4,
          toLayer: 5,
          isAllowedException: true,
        ),
        EdgeKind.allowedException,
      );
      expect(edgeCountLabel(1, EdgeKind.allowedException), '1 (wyjątek)');
      expect(edgeKindStyle[EdgeKind.upLayer], contains('#d1242f'));
      expect(
        edgeKindStyle[EdgeKind.bypassProviders],
        contains('stroke-dasharray'),
      );
      expect(edgeKindStyle.containsKey(EdgeKind.normal), isFalse);
    });
  });

  group('members', () {
    test(
      'sanitizes generics and drops characters Mermaid treats as syntax',
      () {
        expect(sanitizeMember('List<Player>?'), 'List~Player~?');
        expect(
          sanitizeMember('Map<String, List<Player>>'),
          'Map~String, List~Player~~',
        );
        expect(sanitizeMember('a{b}#c;'), 'abc');
      },
    );

    test('truncates on a parameter boundary and keeps tildes balanced', () {
      final parts = [
        'Set~String~? playerIds',
        'Set~String~? teamIds',
        'Set~String~? tradeOfferIds',
        'Set~String~? negotiationIds',
      ];
      final limited = limitParameterList(parts);
      expect(limited, endsWith('...'));
      expect(limited.contains('negotiationIds'), isFalse);
      expect(tildesBalanced(limited), isTrue);
      expect(
        mermaidProblem(
          'classDiagram\n    class Box {\n        +f($limited) int\n    }',
        ),
        isNull,
      );
      expect(mermaidProblem('class A {\n    +List~Player id\n}'), isNotNull);
    });
  });

  group('ref.watch and ref.read', () {
    test('resolves providers, modifiers and family calls', () {
      final uses = extractRefUses('''
void f(dynamic ref, dynamic key) {
  ref.watch(balanceProvider);
  ref.read(gameControllerProvider.notifier);
  ref.watch(savesListProvider.future);
  ref.watch(searchFiltersProvider(key));
  ref.watch(activeLeagueProvider.select((v) => v));
  ref.read(helper());
  ref.watch(unknownThing);
}
''');
      expect(uses.map((use) => use.provider).toList(), [
        'balanceProvider',
        'gameControllerProvider',
        'savesListProvider',
        'searchFiltersProvider',
        'activeLeagueProvider',
        null,
        null,
      ]);
      expect(uses[0].kind, RefKind.watch);
      expect(uses[1].kind, RefKind.read);
      expect(uses[5].resolved, isFalse);
      expect(uses[5].snippet, 'helper()');
      expect(uses[6].snippet, 'unknownThing');
    });

    test(
      'builds provider edges from callbacks and the class that receives ref',
      () {
        final diagram = analyzeProviderSources({
          'providers.dart': '''
class GameController with _Extra {
  GameController(this._ref);
  final Object _ref;
  Object get repo => _ref.read(saveRepositoryProvider);
}
mixin _Extra {
  Object get _ref;
  void go() { _ref.read(tradeServiceProvider); }
}
final gameControllerProvider =
    StateNotifierProvider<GameController, AsyncValue<GameSave?>>((ref) {
  return GameController(ref);
});
final balanceProvider = Provider<BalanceConfig>((ref) => BalanceConfig());
final dayPipelineProvider = Provider((ref) => DayPipeline(
  balance: ref.watch(balanceProvider),
));
final activeLeagueProvider = Provider((ref) {
  return ref.watch(gameControllerProvider).value;
});
final aliasProvider = balanceProvider;
final mysteryProvider = Provider((ref) {
  final value = ref.watch(picked);
  return value;
});
''',
        });
        final types = {
          for (final node in diagram.nodes) node.name: node.exposedType,
        };
        expect(types['gameControllerProvider'], 'AsyncValue~GameSave?~');
        expect(types['balanceProvider'], 'BalanceConfig');
        expect(types['dayPipelineProvider'], 'DayPipeline');
        expect(types['activeLeagueProvider'], isNull);
        expect(types['aliasProvider'], 'BalanceConfig');
        expect(
          diagram.edges.map(
            (edge) => '${edge.from} ${edge.kind.name} ${edge.to}',
          ),
          [
            'activeLeagueProvider watch gameControllerProvider',
            'dayPipelineProvider watch balanceProvider',
            'gameControllerProvider read saveRepositoryProvider',
            'gameControllerProvider read tradeServiceProvider',
          ],
        );
        expect(
          diagram.nodes
              .singleWhere((node) => node.name == 'mysteryProvider')
              .unresolved,
          isTrue,
        );
        expect(diagram.unresolved.single.snippet, 'picked');
      },
    );
  });

  group('polishTyp', () {
    test('inflects typ, typy and typów', () {
      expect(polishTyp(1), '1 typ');
      expect(polishTyp(2), '2 typy');
      expect(polishTyp(4), '4 typy');
      expect(polishTyp(5), '5 typów');
      expect(polishTyp(12), '12 typów');
      expect(polishTyp(14), '14 typów');
      expect(polishTyp(22), '22 typy');
      expect(polishTyp(32), '32 typy');
      expect(polishTyp(34), '34 typy');
    });
  });
}
