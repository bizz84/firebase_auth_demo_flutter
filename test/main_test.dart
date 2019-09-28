import 'dart:async';

import 'package:firebase_auth_demo_flutter/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
  }

  testWidgets('', (WidgetTester tester) async {
    await pumpApp(tester);
  });
}
