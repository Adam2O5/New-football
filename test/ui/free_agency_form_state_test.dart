@Tags(['ui'])
library;

import 'package:flutter_test/flutter_test.dart';

import '../helpers/widgets/stateful_screen_harness.dart';

void main() {
  for (final language in ['pl', 'en']) {
    testWidgets(
      'fa keeps selection and form across locale rebuild ($language)',
      (tester) async {
        await expectMarketFormState(tester, 'fa', language);
      },
    );
  }
}
