import 'package:new_football/core/balance/message_templates_en.dart';
import 'package:new_football/core/balance/message_templates_pl.dart';
import 'package:new_football/core/models/message.dart';

/// Resolves a [GameMessage]'s `titleKey`/`bodyKey`/`args` into displayable
/// text using a per-language template catalog (e.g. [MessageTemplatesPl]).
/// Each catalog keys entries by `titleKey` only; `bodyKey` is not used for
/// lookup, since a single template entry already carries both `title` and
/// `body`.
class MessageTextService {
  /// Registered template catalogs by language code. An unrecognized
  /// [languageCode] passed to [resolve] falls back to `'en'`, matching the
  /// app's existing localization fallback behavior.
  static const _catalogs = {
    'pl': MessageTemplatesPl.templates,
    'en': MessageTemplatesEn.templates,
  };

  /// Resolves the title and body text for [message] in [languageCode].
  ///
  /// Placeholder values are looked up in `message.args` first, then
  /// `message.payload` — matching the merge order `MessageService._expand`
  /// already uses for `groupKey`/`dedupKey`, since callers may put
  /// display-relevant values in either map.
  ///
  /// Throws a [StateError] if no template exists for `message.titleKey` in
  /// the selected catalog, or if `title`/`body` reference a placeholder
  /// missing from both maps.
  static ({String title, String body}) resolve(
    GameMessage message, {
    String languageCode = 'pl',
  }) {
    final catalog = _catalogs[languageCode] ?? _catalogs['en']!;
    final template = catalog[message.titleKey];
    if (template == null) {
      throw StateError(
        'No message template for titleKey "${message.titleKey}" '
        '(language: $languageCode, message id: ${message.id}, '
        'type: ${message.type.name}, kind: ${message.kind}).',
      );
    }
    final values = {...message.args, ...message.payload};
    return (
      title: _interpolate(template.title, values, message),
      body: _interpolate(template.body, values, message),
    );
  }

  static String _interpolate(
    String pattern,
    Map<String, dynamic> args,
    GameMessage message,
  ) {
    return pattern.replaceAllMapped(RegExp(r'\{(\w+)\}'), (match) {
      final placeholder = match.group(1)!;
      if (!args.containsKey(placeholder)) {
        throw StateError(
          'Missing arg "$placeholder" for message titleKey '
          '"${message.titleKey}" (message id: ${message.id}).',
        );
      }
      return args[placeholder].toString();
    });
  }
}
