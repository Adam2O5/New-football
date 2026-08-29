import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/services/message_text_service.dart';
import 'package:test/test.dart';

GameMessage _message({
  required String titleKey,
  required String bodyKey,
  Map<String, dynamic> args = const {},
}) {
  return GameMessage(
    id: 'test-id',
    type: MessageType.walkover,
    seasonYear: 2025,
    week: 3,
    titleKey: titleKey,
    bodyKey: bodyKey,
    args: args,
  );
}

void main() {
  group('MessageTextService.resolve', () {
    test('podstawia wszystkie argumenty w title i body', () {
      final message = _message(
        titleKey: 'msg_walkover_title',
        bodyKey: 'msg_walkover_body',
        args: const {'reason': 'Brak zawodników', 'opponentName': 'FC Testowy'},
      );

      final result = MessageTextService.resolve(message);

      expect(result.title, 'Zagrożenie walkowerem');
      expect(
        result.body,
        'Nie możesz rozegrać meczu zgodnie z regulaminem. Powód: Brak '
        'zawodników. Uzupełnij skład przed spotkaniem z FC Testowy, aby '
        'uniknąć walkowera.',
      );
    });

    test('rzuca StateError, gdy titleKey nie istnieje w katalogu', () {
      final message = _message(
        titleKey: 'msg_nieistniejacy_klucz_title',
        bodyKey: 'msg_nieistniejacy_klucz_body',
      );

      expect(
        () => MessageTextService.resolve(message),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('msg_nieistniejacy_klucz_title'),
          ),
        ),
      );
    });

    test('rzuca StateError, gdy brakuje wartości dla placeholdera', () {
      final message = _message(
        titleKey: 'msg_walkover_title',
        bodyKey: 'msg_walkover_body',
        args: const {'reason': 'Brak zawodników'}, // brak opponentName
      );

      expect(
        () => MessageTextService.resolve(message),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('opponentName'),
          ),
        ),
      );
    });
  });
}
