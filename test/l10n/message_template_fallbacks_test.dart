@Tags(['unit'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/balance/message_catalog.dart';
import 'package:new_football/core/balance/message_templates_en.dart';
import 'package:new_football/core/balance/message_templates_pl.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/services/message_text_service.dart';

const _types = [
  MessageType.playerEvent,
  MessageType.teamEvent,
  MessageType.retirementLeagueDigest,
  MessageType.contractExpiring,
  MessageType.contractLostToRival,
  MessageType.contractExpired,
  MessageType.tradeWindowEvent,
  MessageType.draftPickLeague,
  MessageType.ovrDigest,
];
const _args = {
  'playerName': 'Jan Testowy',
  'subjectName': 'Adam Testowy',
  'rivalTeam': 'Klub Testowy',
};

void main() {
  for (final language in ['pl', 'en']) {
    final arb =
        jsonDecode(File('lib/l10n/app_$language.arb').readAsStringSync())
            as Map<String, dynamic>;
    final templates = language == 'pl'
        ? MessageTemplatesPl.templates
        : MessageTemplatesEn.templates;
    for (final type in _types) {
      test(
        '$language ${type.name}: generic text renders and catalog precedence is preserved',
        () {
          final titleKey = 'msg_${type.name}_title';
          final bodyKey = 'msg_${type.name}_body';
          final template = templates[titleKey];
          expect(template, isNotNull);
          expect(template!.key, titleKey);
          expect(template.title, arb[titleKey]);
          expect(template.body, arb[bodyKey]);

          String interpolate(String text) {
            for (final entry in _args.entries) {
              text = text.replaceAll('{${entry.key}}', entry.value);
            }
            return text;
          }

          final isDigest =
              type == MessageType.retirementLeagueDigest ||
              type == MessageType.ovrDigest;
          for (final kind in [null, 'unknown-kind']) {
            final selected = MessageCatalog.resolve(type, kind: kind);
            expect(
              selected.titleKey,
              isDigest ? 'msg_${type.name}_digest_title' : titleKey,
            );
            expect(
              selected.bodyKey,
              isDigest ? 'msg_${type.name}_digest_body' : bodyKey,
            );
            final message = GameMessage(
              id: 'fallback',
              type: type,
              kind: kind,
              seasonYear: 2026,
              week: 1,
              titleKey: titleKey,
              bodyKey: bodyKey,
              args: _args,
            );
            final resolved = MessageTextService.resolve(
              message,
              languageCode: language,
            );
            expect(resolved, (
              title: interpolate(arb[titleKey] as String),
              body: interpolate(arb[bodyKey] as String),
            ));
            expect(resolved.title, isNot(contains('{')));
            expect(resolved.body, isNot(contains('{')));

            final withoutArgs = message.copyWith(args: {});
            if (type == MessageType.contractExpiring ||
                type == MessageType.contractLostToRival ||
                type == MessageType.contractExpired) {
              expect(
                MessageTextService.tryResolve(
                  withoutArgs,
                  languageCode: language,
                ),
                isNull,
              );
              expect(
                () => MessageTextService.resolve(
                  withoutArgs,
                  languageCode: language,
                ),
                throwsStateError,
              );
            } else {
              expect(
                MessageTextService.resolve(withoutArgs, languageCode: language),
                resolved,
              );
            }
          }
        },
      );
    }
  }
}
