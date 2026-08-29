import 'package:new_football/core/balance/message_catalog.dart';
import 'package:new_football/core/balance/message_templates_en.dart';
import 'package:new_football/core/balance/message_templates_pl.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/services/message_text_service.dart';
import 'package:test/test.dart';

final _placeholderPattern = RegExp(r'\{(\w+)\}');

Set<String> _placeholdersIn(String text) =>
    _placeholderPattern.allMatches(text).map((m) => m.group(1)!).toSet();

/// Enumerates every `(type, kind)` combination defined in [MessageCatalog]
/// and asserts each one has a matching PL/EN template with an identical
/// placeholder set. This does NOT verify that real callers actually supply
/// those args — see the debug `assert` in `MessageService.send()` for that;
/// this test only guarantees the catalog and the two locale files agree with
/// each other, regardless of whether a given `kind` is ever exercised at
/// runtime.
void main() {
  group('MessageCatalog <-> template consistency', () {
    for (final template in MessageCatalog.templates) {
      final label = template.kind == null
          ? template.type.name
          : '${template.type.name}/${template.kind}';

      test(label, () {
        final plTemplate = MessageTemplatesPl.templates[template.titleKey];
        final enTemplate = MessageTemplatesEn.templates[template.titleKey];

        expect(
          plTemplate,
          isNotNull,
          reason: 'Missing PL template for titleKey "${template.titleKey}" '
              '($label).',
        );
        expect(
          enTemplate,
          isNotNull,
          reason: 'Missing EN template for titleKey "${template.titleKey}" '
              '($label).',
        );
        if (plTemplate == null || enTemplate == null) return;

        final plPlaceholders = {
          ..._placeholdersIn(plTemplate.title),
          ..._placeholdersIn(plTemplate.body),
        };
        final enPlaceholders = {
          ..._placeholdersIn(enTemplate.title),
          ..._placeholdersIn(enTemplate.body),
        };
        expect(
          enPlaceholders,
          plPlaceholders,
          reason:
              'PL/EN placeholder sets differ for "${template.titleKey}" '
              '($label). PL: $plPlaceholders, EN: $enPlaceholders.',
        );

        final dummyArgs = {for (final key in plPlaceholders) key: 'x'};
        final message = GameMessage(
          id: 'catalog-check',
          type: template.type,
          kind: template.kind,
          seasonYear: 2025,
          week: 1,
          titleKey: template.titleKey,
          bodyKey: template.bodyKey,
          args: dummyArgs,
        );

        expect(
          () => MessageTextService.resolve(message, languageCode: 'pl'),
          returnsNormally,
        );
        expect(
          () => MessageTextService.resolve(message, languageCode: 'en'),
          returnsNormally,
        );
      });
    }
  });
}
