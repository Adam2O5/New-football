@Tags(['ui'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/contract_negotiation.dart';

import '../helpers/widgets/stateful_screen_harness.dart';

void main() {
  for (final language in ['pl', 'en']) {
    testWidgets(
      'staff keeps selection and form across locale rebuild ($language)',
      (tester) async {
        await expectMarketFormState(tester, 'staff', language);
      },
    );
  }
  testWidgets('counter validates, cancels and reopens cleanly', (tester) async {
    await expectCounterDialogState(tester, NegotiationSubjectKind.staff);
  });
}
