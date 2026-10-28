import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

/// Registers release before group teardown even if the test fails early.
void releaseOnTearDown(Completer<void> barrier) {
  addTearDown(() {
    if (!barrier.isCompleted) barrier.complete();
  });
}
