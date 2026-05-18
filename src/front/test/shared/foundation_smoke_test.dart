import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'widget_test_helpers.dart';

void main() {
  testWidgets('pumpApp renders child widget', (tester) async {
    await tester.pumpApp(const Text('test-foundation'));

    expect(find.text('test-foundation'), findsOneWidget);
  });
}
