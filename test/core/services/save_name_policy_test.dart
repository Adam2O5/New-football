import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/services/save_name_policy.dart';

void main() {
  group('SaveNamePolicy', () {
    test(
      'trims leading and trailing whitespace without changing inner text',
      () {
        expect(SaveNamePolicy.trimName('  Sezon 1 \n'), 'Sezon 1');
        expect(
          SaveNamePolicy.trimName('  Nazwa  z odstępem  '),
          'Nazwa  z odstępem',
        );
      },
    );

    test('rejects whitespace-only names', () {
      expect(SaveNamePolicy.trimName(' \t\n '), isEmpty);
      expect(
        () => SaveNamePolicy.nameKey(' \t\n '),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => SaveNamePolicy.copyName('  ', 'pl', <String>{}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('compares names without case or Polish diacritics', () {
      expect(
        SaveNamePolicy.nameKey('  ŚLĄSK ŁÓDŹ  '),
        SaveNamePolicy.nameKey('slask lodz'),
      );
      expect(SaveNamePolicy.nameKey('ĄĆĘŁŃÓŚŹŻ'), 'acelnoszz');
    });

    test('uses the localized suffix for English and Polish copies', () {
      expect(
        SaveNamePolicy.copyName('Sezon 1', 'en', <String>{}),
        'Sezon 1-copy',
      );
      expect(
        SaveNamePolicy.copyName('Sezon 1', 'pl-PL', <String>{}),
        'Sezon 1-kopia',
      );
    });

    test('chooses the smallest available numbered suffix', () {
      final occupiedEnglish = <String>{
        'Sezon-copy',
        'Sezon-copy-2',
        'Sezon-copy-4',
      };
      expect(
        SaveNamePolicy.copyName('Sezon', 'en', occupiedEnglish),
        'Sezon-copy-3',
      );

      final occupiedPolish = <String>{
        'łódź-kopia',
        'LODZ-KOPIA-2',
        'ŁÓDŹ-kopia-4',
      };
      expect(
        SaveNamePolicy.copyName('Łódź', 'pl', occupiedPolish),
        'Łódź-kopia-3',
      );
    });
  });
}
